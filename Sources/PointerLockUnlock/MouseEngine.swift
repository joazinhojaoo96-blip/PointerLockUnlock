import Foundation
import GameController

@MainActor
final class MouseEngine: ObservableObject {
    @Published var isConnected = false
    @Published var deviceName = "Procurando mouse…"
    @Published var lastX: CGFloat = 0
    @Published var lastY: CGFloat = 0
    @Published var totalX: CGFloat = 0
    @Published var totalY: CGFloat = 0
    @Published var sensitivity: Double = 1.0
    @Published var invertY = false
    @Published var virtualLockEnabled = false
    @Published var statusMessage = "Conecte um mouse USB ou Bluetooth."

    private var trackedMouse: GCMouse?
    private var connectObserver: NSObjectProtocol?
    private var disconnectObserver: NSObjectProtocol?

    init() {
        connectObserver = NotificationCenter.default.addObserver(
            forName: .GCMouseDidConnect, object: nil, queue: .main
        ) { [weak self] note in
            Task { @MainActor in
                guard let mouse = note.object as? GCMouse else { return }
                self?.attach(mouse)
            }
        }
        disconnectObserver = NotificationCenter.default.addObserver(
            forName: .GCMouseDidDisconnect, object: nil, queue: .main
        ) { [weak self] note in
            Task { @MainActor in
                guard let mouse = note.object as? GCMouse else { return }
                if self?.trackedMouse === mouse {
                    self?.trackedMouse = nil
                    self?.isConnected = false
                    self?.deviceName = "Mouse desconectado"
                    self?.statusMessage = "Conecte o mouse novamente."
                }
            }
        }
        if let mouse = GCMouse.current {
            attach(mouse)
        } else {
            statusMessage = "Aguardando dispositivo apontador reconhecido pelo GameController."
        }
    }

    deinit {
        if let connectObserver { NotificationCenter.default.removeObserver(connectObserver) }
        if let disconnectObserver { NotificationCenter.default.removeObserver(disconnectObserver) }
    }

    func refresh() {
        if let mouse = GCMouse.current {
            attach(mouse)
        } else {
            statusMessage = "Nenhum mouse exposto ao GameController. O iOS ainda pode mostrar o cursor de acessibilidade."
        }
    }

    private func attach(_ mouse: GCMouse) {
        guard let input = mouse.mouseInput else {
            statusMessage = "Mouse encontrado, mas sem interface de movimento disponível."
            return
        }
        trackedMouse = mouse
        isConnected = true
        deviceName = "Mouse detectado"
        statusMessage = "Movimento relativo recebido dentro deste app."
        input.mouseMovedHandler = { [weak self] _, x, y in
            Task { @MainActor in
                guard let self else { return }
                let dx = CGFloat(x) * CGFloat(self.sensitivity)
                let rawY = CGFloat(y) * CGFloat(self.sensitivity)
                let dy = self.invertY ? -rawY : rawY
                self.lastX = dx
                self.lastY = dy
                self.totalX += dx
                self.totalY += dy
            }
        }
    }

    func toggleVirtualLock() {
        virtualLockEnabled.toggle()
        statusMessage = virtualLockEnabled
            ? "Modo virtual ativo nesta tela. Não é um bloqueio global do iOS."
            : "Modo virtual desativado."
    }

    func resetCounters() {
        lastX = 0
        lastY = 0
        totalX = 0
        totalY = 0
    }
}
