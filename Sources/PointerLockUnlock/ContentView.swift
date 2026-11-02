import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var engine = MouseEngine()
    @State private var selectedTab = 0
    @State private var showingImporter = false
    @State private var importedFiles: [String] = []
    @State private var importMessage = "Nenhum arquivo importado"

    private let accent = Color(red: 0.36, green: 0.78, blue: 1.0)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.035, green: 0.055, blue: 0.12), Color(red: 0.07, green: 0.10, blue: 0.20), .black],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                if selectedTab == 0 { dashboard }
                else if selectedTab == 1 { filesScreen }
                else { aboutScreen }
                Spacer(minLength: 8)
                tabBar
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.data, .json, .plainText, .zip],
            allowsMultipleSelection: true
        ) { result in
            handleImport(result)
        }
        .onAppear { engine.refresh() }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 15).fill(accent.opacity(0.16))
                Image(systemName: "cursorarrow.motionlines")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundStyle(accent)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                Text("POINTER LOCK UNLOCK")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .tracking(1.0)
                    .foregroundStyle(.white)
                Text("VIRTUAL POINTER ENGINE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(2.0)
                    .foregroundStyle(accent)
            }
            Spacer()
            Circle()
                .fill(engine.isConnected ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            Text(engine.isConnected ? "MOUSE ON" : "WAITING")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 18)
    }

    private var dashboard: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                heroCard
                HStack(spacing: 12) {
                    metricCard(title: "DELTA X", value: engine.lastX, icon: "arrow.left.and.right")
                    metricCard(title: "DELTA Y", value: engine.lastY, icon: "arrow.up.and.down")
                }
                movementCard
                settingsCard
                statusCard
                Text("Este app testa a captura de movimentos dentro dele. Para mover a câmera do Minecraft, o mecanismo precisa ser integrado ao Amethyst.")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 12)
            }
            .padding(.horizontal, 18)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("EXPERIMENTAL FEATURE", systemImage: "sparkles")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1)
                    .foregroundStyle(accent)
                Spacer()
                Text("v0.1.0")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Text("Pointer Lock\nUnlock")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text("Uma camada de ponteiro virtual que usa os movimentos relativos do mouse, sem depender de um cursor preso no centro.")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.68))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                engine.toggleVirtualLock()
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: engine.virtualLockEnabled ? "lock.open.fill" : "scope")
                    Text(engine.virtualLockEnabled ? "DESATIVAR MODO VIRTUAL" : "ATIVAR POINTER LOCK UNLOCK")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(Color.black.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 15)
                .background(LinearGradient(colors: [accent, Color(red: 0.43, green: 0.95, blue: 0.83)], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            Text(engine.virtualLockEnabled ? "VIRTUAL MODE ACTIVE · APP-LOCAL" : "SYSTEM POINTER LOCK IS NOT MODIFIED")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .tracking(0.7)
                .foregroundStyle(engine.virtualLockEnabled ? .green : .white.opacity(0.42))
        }
        .padding(19)
        .background(.white.opacity(0.065))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.11), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var movementCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("MOVEMENT MONITOR")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.1)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Button("RESET") { engine.resetCounters() }
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(accent)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.22))
                GeometryReader { proxy in
                    Path { path in
                        let midX = proxy.size.width / 2
                        let midY = proxy.size.height / 2
                        path.move(to: CGPoint(x: midX, y: 0))
                        path.addLine(to: CGPoint(x: midX, y: proxy.size.height))
                        path.move(to: CGPoint(x: 0, y: midY))
                        path.addLine(to: CGPoint(x: proxy.size.width, y: midY))
                    }.stroke(.white.opacity(0.10), style: StrokeStyle(lineWidth: 1, dash: [4, 5]))
                    Circle()
                        .fill(accent)
                        .frame(width: 9, height: 9)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    Circle()
                        .stroke(accent.opacity(0.45), lineWidth: 1)
                        .frame(width: 30, height: 30)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                }
            }
            .frame(height: 112)
            HStack {
                totalLabel("TOTAL X", value: engine.totalX)
                Spacer()
                totalLabel("TOTAL Y", value: engine.totalY)
            }
        }
        .padding(16)
        .background(.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("POINTER SETTINGS")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .tracking(1.1)
                .foregroundStyle(.white.opacity(0.7))
            HStack {
                Label("Sensitivity", systemImage: "speedometer")
                    .font(.system(size: 13, weight: .medium))
                Spacer()
                Text("\(engine.sensitivity, specifier: "%.1f")×")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(accent)
            }
            Slider(value: $engine.sensitivity, in: 0.2...3.0, step: 0.1).tint(accent)
            Toggle(isOn: $engine.invertY) {
                Label("Invert vertical axis", systemImage: "arrow.up.and.down")
                    .font(.system(size: 13, weight: .medium))
            }
            .tint(accent)
        }
        .padding(16)
        .background(.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var statusCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: engine.isConnected ? "checkmark.circle.fill" : "info.circle.fill")
                .foregroundStyle(engine.isConnected ? .green : .orange)
                .font(.system(size: 19))
            VStack(alignment: .leading, spacing: 4) {
                Text(engine.deviceName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text(engine.statusMessage)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.58))
            }
            Spacer()
            Button { engine.refresh() } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundStyle(accent)
                    .padding(8)
                    .background(.white.opacity(0.07))
                    .clipShape(Circle())
            }
        }
        .padding(15)
        .background(.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var filesScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("IMPORT CENTER")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Escolha arquivos manualmente pelo seletor seguro do iOS. O app não acessa nem extrai arquivos privados do iPhone.")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.62))
                Button { showingImporter = true } label: {
                    Label("ESCOLHER ARQUIVOS DO IPHONE", systemImage: "folder.badge.plus")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(accent)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                Text(importMessage)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.6))
                ForEach(importedFiles, id: \.self) { name in
                    HStack {
                        Image(systemName: "doc")
                            .foregroundStyle(accent)
                        Text(name).font(.system(size: 12)).foregroundStyle(.white)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                    .padding(12)
                    .background(.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
        }
    }

    private var aboutScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("ABOUT THE ENGINE")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                infoBlock("O que ele faz", "Tenta receber eventos relativos do mouse usando GameController e demonstra um ponteiro virtual dentro desta aplicação.")
                infoBlock("O que ele não faz", "Não desbloqueia o Pointer Lock nativo da Apple, não altera o cursor global do iOS e não injeta movimentos em outros aplicativos.")
                infoBlock("Integração Minecraft", "Para girar a câmera no Amethyst, o processamento dos eventos precisa ser incorporado ao código-fonte do launcher.")
                infoBlock("Privacidade", "Arquivos só são importados quando você os seleciona explicitamente no seletor de documentos do iOS.")
                Text("MOUSEBRIDGE LABS  ·  EXPERIMENTAL")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1)
                    .foregroundStyle(accent.opacity(0.8))
                    .padding(.top, 10)
            }
            .padding(20)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton("Pointer", icon: "scope", index: 0)
            tabButton("Arquivos", icon: "folder", index: 1)
            tabButton("Sobre", icon: "info.circle", index: 2)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(.black.opacity(0.35))
    }

    private func tabButton(_ title: String, icon: String, index: Int) -> some View {
        Button { selectedTab = index } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 17, weight: .semibold))
                Text(title).font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(selectedTab == index ? accent : .white.opacity(0.45))
            .frame(maxWidth: .infinity)
        }
    }

    private func metricCard(title: String, value: CGFloat, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.55))
            Text(value, format: .number.precision(.fractionLength(2)))
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(15)
        .background(.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func totalLabel(_ title: String, value: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 8, weight: .bold)).foregroundStyle(.white.opacity(0.45))
            Text(value, format: .number.precision(.fractionLength(1)))
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }

    private func infoBlock(_ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
            Text(detail).font(.system(size: 12)).foregroundStyle(.white.opacity(0.62))
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.055))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            let fm = FileManager.default
            let folder = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("Imported", isDirectory: true)
            do {
                try fm.createDirectory(at: folder, withIntermediateDirectories: true)
                for url in urls {
                    let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    let destination = folder.appendingPathComponent(url.lastPathComponent)
                    if fm.fileExists(atPath: destination.path) {
                        try fm.removeItem(at: destination)
                    }
                    try fm.copyItem(at: url, to: destination)
                    importedFiles.append(url.lastPathComponent)
                }
                importMessage = "\(urls.count) arquivo(s) copiado(s) para a área privada do app."
            } catch {
                importMessage = "Falha ao importar: \(error.localizedDescription)"
            }
        case .failure(let error):
            importMessage = "Importação cancelada ou falhou: \(error.localizedDescription)"
        }
    }
}
