# Conectarse por SSH

Te conectas siempre al **nodo de entrada** de Chuchunco, que se llama `chuchunco`. Por ahora, usa su dirección IP:

| | |
|---|---|
| **Dirección** | `158.170.68.170` |
| **Usuario** | la parte de tu correo USACH antes de la `@` (por ejemplo `nombre.apellido`) |
| **Acceso** | solo con **llave SSH** (no hay contraseña) |

El nombre `chuchunco.c3p.usach.cl` todavía no funciona. Avisaremos cuando funcione; mientras tanto, usa la IP.

!!! info "¿Desde dónde puedo conectarme?"
    - Desde la **red cableada** de cualquier unidad de la USACH.
    - Desde fuera de la universidad (o por WiFi) usando la **VPN USACH**.

    No hay acceso directo desde internet.

## 1. Genera tu llave SSH

Una llave SSH son dos archivos: una **llave privada**, que nunca sale de tu computador, y una **llave pública** (`.pub`), que nos envías en el formulario.

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

Acepta la ubicación por defecto y elige una frase de paso (*passphrase*). La frase de paso protege tu llave si alguien copia tu computador.

## 2. Conéctate

```bash
ssh nombre.apellido@158.170.68.170
```

La primera vez, SSH te pregunta si confías en el servidor (`Are you sure you want to continue connecting?`). Responde `yes`.

Cuando entres, verás algo como `nombre.apellido@chuchunco:~$`. Ya estás en el nodo de entrada. Sigue con [Tu primer trabajo en 15 minutos](../uso/primeros-pasos.md).

## 3. (Opcional) Crea un atajo

Agrega esto a `~/.ssh/config` en tu computador:

```text
Host chuchunco
    HostName 158.170.68.170
    User nombre.apellido
    IdentityFile ~/.ssh/id_ed25519
```

Desde ahora basta con `ssh chuchunco`, `scp archivo chuchunco:` o `rsync -avP datos/ chuchunco:datos/`.

## Solo el nodo de entrada acepta SSH

Los nodos de cómputo (`cpun1`, `gpun2`, etc.) **no aceptan SSH de usuarios**: `ssh cpun1` responde `Permission denied`. Tampoco sirve saltar a ellos con `ssh -J` o `ProxyJump`: esas configuraciones no son para usuarios y no funcionan.

Para trabajar en un nodo de cómputo, pídeselo a Slurm:

- un trabajo por lotes con `sbatch` ([Primeros pasos](../uso/primeros-pasos.md)), o
- una sesión interactiva con `srun --pty bash` ([Slurm](../uso/slurm.md#sesion-interactiva)).

## Si la conexión «se queda pegada»

Casi siempre es la red: el terminal espera y nunca pide la frase de paso. Prueba conectándote por VPN. Si sigue fallando, escribe a hpc.fisica@usach.cl indicando tu usuario, la red desde la que te conectas y la salida de:

```bash
ssh -v nombre.apellido@158.170.68.170
```
