# Conectarse por SSH

Te conectas siempre al **nodo de entrada** de Chuchunco, que se llama `chuchunco`. Por ahora, usa su dirección IP:

| | |
|---|---|
| **Dirección** | `158.170.68.170` |
| **Usuario** | la parte de tu correo USACH antes de la `@` (por ejemplo `nombre.apellido`) |
| **Acceso** | solo con **llave SSH** (no hay contraseña) |

El nombre `chuchunco.c3p.usach.cl` todavía no funciona. Avisaremos cuando funcione; mientras tanto, usa la IP.

!!! info "¿Desde dónde puedo conectarme?"
    El cortafuegos de la universidad deja pasar las conexiones SSH a Chuchunco solo desde:

    - **algunas redes cableadas** de la USACH, y
    - la **VPN USACH**, cuando tu acceso ya está habilitado. La habilitación es persona por persona: la gestionamos nosotros.

    No hay acceso directo desde internet. Si la conexión se queda en `Connecting…`, ver [Si la conexión «se queda pegada»](#si-la-conexion-se-queda-pegada).

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

## Conectarte desde otro computador

Puedes tener **varias llaves**, una por computador. Tus llaves están en el archivo `~/.ssh/authorized_keys` de tu cuenta en el clúster, una línea por llave (el mismo archivo sirve para todos los nodos).

Si todavía puedes entrar desde un computador:

1. En el computador nuevo, crea una llave como en [Genera tu llave SSH](#1-genera-tu-llave-ssh).
2. Copia el contenido del archivo `.pub` nuevo.
3. Desde el computador que funciona, entra al clúster y agrega la llave nueva:

    ```bash
    echo 'ssh-ed25519 AAAA... nombre@computador-nuevo' >> ~/.ssh/authorized_keys
    ```

    Van **dos** signos `>`: con uno solo borrarías tus otras llaves.

4. Prueba la conexión desde el computador nuevo.

!!! danger "No copies tu llave privada"
    Nunca copies tu llave privada de un computador a otro: crea una llave nueva en cada uno.

Si no puedes entrar desde ningún computador, escribe a hpc.fisica@usach.cl. Una opción «llave adicional» en el formulario está en preparación (por confirmar).

Si crees que una llave pudo filtrarse, usa la opción **cambio de llave** del formulario [Unirse a un proyecto](unirse.md#cambiar-tu-llave-o-unirte-a-otro-proyecto): reemplaza **todas** tus llaves por la nueva.

## Si la conexión «se queda pegada»

Si el terminal se queda en `Connecting…` y nunca pide la frase de paso, es el cortafuegos de la universidad: la red desde la que te conectas no está habilitada, o tu acceso por VPN todavía no lo está.

Escribe a hpc.fisica@usach.cl con:

- tu nombre de usuario,
- la red desde la que te conectas (qué red cableada de la USACH, o VPN),
- la salida de:

    ```bash
    ssh -v nombre.apellido@158.170.68.170
    ```

Con eso pedimos a la unidad de informática de la universidad (SEGIC) que te habilite. Pedimos a SEGIC un proceso más simple (por ejemplo, un grupo de VPN para el clúster): por confirmar.
