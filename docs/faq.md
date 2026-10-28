# Preguntas frecuentes

## Conexión

??? question "Mi conexión SSH se queda esperando y nunca pide la frase de paso"
    Es un problema de red: solo se puede entrar desde la red cableada USACH o por VPN. Conéctate a la VPN y prueba de nuevo. Ver [Conectarse](acceso/conectarse.md#si-la-conexion-se-queda-pegada).

??? question "Me dice `Permission denied (publickey)`"
    El servidor no reconoce tu llave. Revisa que pegaste en el formulario el contenido del archivo `.pub` correcto y que usas el usuario correcto. Prueba `ssh -i ~/.ssh/id_ed25519 nombre.apellido@158.170.68.170`.

    Si te pasa al hacer `ssh` a un nodo de cómputo (`ssh cpun1`), es normal: los nodos de cómputo no aceptan SSH de usuarios. Usa `srun --pty bash` ([Sesión interactiva](uso/slurm.md#sesion-interactiva)).

## Trabajos

??? question "Mi trabajo está PENDING (`PD`) hace mucho rato"
    Mira la razón en la columna `NODELIST(REASON)` de `squeue -u $USER`:

    - `Priority`: hay trabajos con más prioridad antes que el tuyo. Van primero los proyectos que han usado menos el clúster recientemente.
    - `Resources`: eres el siguiente, pero aún no hay recursos libres.
    - `QOSMaxCpuPerUserLimit`: ya tienes 512 CPUs en uso. Espera a que terminen tus otros trabajos.
    - `QOSMaxGRESPerUser`: ya tienes 4 GPUs en uso. Lo mismo.
    - `ReqNodeNotAvail`: pediste un nodo que no está disponible ahora (por ejemplo, en mantención).

    Un trabajo pequeño y con `--time` ajustado suele empezar antes. Más detalle en [¿Por qué mi trabajo está pendiente?](uso/slurm.md#por-que-mi-trabajo-esta-pendiente).

??? question "Me dice `Invalid account or account/partition combination specified`"
    Tu cuenta no está asociada a un proyecto aprobado, o pediste un proyecto (`-A`) al que no perteneces. Revisa tus proyectos:

    ```bash
    sacctmgr show assoc user=$USER format=account%30,qos%20
    ```

    Si no aparece ninguno, escribe a hpc.fisica@usach.cl. Si aparece más de uno, elige con `-A <proyecto>`.

??? question "Mi trabajo terminó con `OUT_OF_MEMORY` («Out Of Memory»)"
    Tu programa usó más memoria de la que pediste, y Slurm lo detuvo. No hay *swap*: no se puede pasar del límite.

    En el archivo de salida del trabajo verás líneas como estas (el nodo y los números cambian):

    ```text
    slurmstepd-cpun1: error: Detected 1 oom_kill event in StepId=264.0. Some of the step tasks have been OOM Killed.
    srun: error: cpun1: task 0: Out Of Memory
    ```

    Qué hacer:

    1. Mira cuánto usó: `sacct -j <jobid> -o JobID,Elapsed,MaxRSS,ReqMem,State` (columna `MaxRSS`).
    2. Pide un poco más con `--mem` (por ejemplo `--mem=32G`).

    Si no pones `--mem`, recibes 2,9 GB por CPU en `CPU`, 3,9 GB en `MEM` y 5 GB en `GPU`.

??? question "Mi trabajo terminó con `TIMEOUT`"
    Pasó del tiempo pedido. Si no pusiste `--time`, el límite es 4 horas. Pide más con `--time` (máximo 7 días: `--time=7-00:00:00`). Para cálculos aún más largos, ver [Trabajos más largos que 7 días](uso/ejemplos.md#trabajos-mas-largos-que-7-dias).

??? question "¿Cómo entro al nodo donde corre mi trabajo?"
    No por SSH, sino con `srun`, desde el nodo de entrada:

    ```bash
    srun --jobid=<jobid> --overlap --pty bash
    ```

    Abre una terminal dentro de tu trabajo, en su nodo, y ahí puedes mirar con `top` cuánto usa. `--overlap` es necesario: sin esa opción, `srun` se queda esperando. Solo funciona con tus propios trabajos. Sal con `exit`; el trabajo sigue corriendo. Ver [Entrar a un trabajo que ya está corriendo](uso/slurm.md#entrar-a-un-trabajo-que-ya-esta-corriendo).

??? question "¿Puedo usar más de un nodo?"
    Por defecto, no: cada trabajo usa un solo nodo, y un nodo `CPU` ya tiene 256 CPUs. MPI y multihilo dentro de un nodo funcionan sin problema (`--nodes=1 --ntasks-per-node=…`).

    Si tu programa de verdad necesita varios nodos, el o la responsable de tu proyecto puede pedirlo a hpc.fisica@usach.cl. Se aprueba por proyecto, y entonces se usa `--qos=multinodo`. Ver [Un nodo por trabajo](uso/slurm.md#un-nodo-por-trabajo).

??? question "¿Me llegan correos cuando mi trabajo termina?"
    No, por ahora no. `--mail-type` y `--mail-user` no hacen nada. Revisa tus trabajos con `squeue -u $USER` y, cuando terminen, con `sacct`.

??? question "¿Hay límites por usuario?"
    Sí. Cada trabajo: hasta 7 días y un nodo. Cada persona: hasta 512 CPUs y 4 GPUs en uso al mismo tiempo; los trabajos que pasen de eso esperan en la cola. Ver [Slurm: colas y límites](uso/slurm.md).

## Software

??? question "¿Cómo instalo numpy (u otro paquete de Python)?"
    En tu propio entorno de Python:

    ```bash
    python3 -m venv ~/venvs/ciencia
    source ~/venvs/ciencia/bin/activate
    pip install numpy
    ```

    Y en tu script de trabajo, antes de llamar a Python: `source ~/venvs/ciencia/bin/activate`. Paso a paso en [Software y Python](uso/software.md).

??? question "¿Puedo instalar software?"
    Sí, sin permisos de administrador: paquetes de Python en tu propio entorno ([Software y Python](uso/software.md)), o cualquier otro software con [contenedores](uso/contenedores.md). No hay `sudo` ni `module load`.

??? question "¿Puedo usar Jupyter?"
    No disponible por ahora. Trabaja con scripts y `sbatch`.
