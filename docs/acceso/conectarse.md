# Conectarse por SSH

El nodo de entrada (*head node*) de Chuchunco es **158.170.68.170**.

!!! info "¿Desde dónde puedo conectarme?"
    - Desde la **red cableada** de cualquier unidad de la USACH.
    - Desde fuera de la universidad (o por WiFi) usando la **VPN USACH**.
    
    No hay acceso directo desde internet.

## 1. Genera tu llave SSH

=== "Linux / macOS"
    ```bash
    ssh-keygen -t ed25519 -C "tu.correo@usach.cl"
    cat ~/.ssh/id_ed25519.pub     # esto es lo que pegas en el formulario
    ```

=== "Windows (PowerShell)"
    ```powershell
    ssh-keygen -t ed25519 -C "tu.correo@usach.cl"
    type $env:USERPROFILE\.ssh\id_ed25519.pub
    ```
    Windows 10/11 ya trae el cliente OpenSSH. También puedes usar WSL o MobaXterm.

Acepta la ubicación por defecto y elige una frase de paso (*passphrase*).

## 2. Conéctate

```bash
ssh nombre.apellido@158.170.68.170
```

## 3. (Opcional) Crea un atajo

Agrega esto a `~/.ssh/config` en tu computador:

```text
Host chuchunco
    HostName 158.170.68.170
    User nombre.apellido
    IdentityFile ~/.ssh/id_ed25519
```

Desde ahora basta con `ssh chuchunco`, `scp archivo chuchunco:` o `rsync -avP datos/ chuchunco:/data/...`.

## Si la conexión «se queda pegada»

Casi siempre es la red: el terminal espera y nunca pide la frase de paso. Prueba conectándote por VPN. Si sigue fallando, escribe a hpc.fisica@usach.cl indicando tu usuario, la red desde la que te conectas y la salida de:

```bash
ssh -v nombre.apellido@158.170.68.170
```
