# Slurm: colas y límites

Slurm es el gestor de colas: tú describes qué recursos necesita tu trabajo y Slurm lo ejecuta en un nodo de cómputo cuando esos recursos están libres.

¿Nunca usaste Slurm? Empieza por [Tu primer trabajo en 15 minutos](primeros-pasos.md).

## Particiones

Una partición es un grupo de nodos. Elige la tuya con `-p` (o `--partition`).

| Partición | Nodos | Por nodo | Memoria por defecto |
|---|---|---|---|
| `CPU` *(por defecto)* | `cpun1`–`cpun5` | 2× AMD EPYC 9554 · 256 CPUs · 755 GB RAM | 2,9 GB por CPU |
| `MEM` | `high-ram-n1` | 2× AMD EPYC 9654 · 384 CPUs · 1,5 TB RAM | 3,9 GB por CPU |
| `GPU` | `gpun1` | AMD EPYC 9354P · 64 CPUs · 503 GB RAM · **4× AMD MI210** | 5 GB por CPU |
| `GPU` | `gpun2`, `gpun3` | AMD EPYC 7443 · 48 CPUs · 251 GB RAM · **4× NVIDIA RTX 6000 Ada** | 5 GB por CPU |

En todas las particiones:

- **Tiempo por defecto: 4 horas.** Si no pones `--time`, tu trabajo se detiene a las 4 horas.
- **Tiempo máximo: 7 días** (`--time=7-00:00:00`).
- **Un nodo por trabajo.** Ver [abajo](#un-nodo-por-trabajo).

!!! note "¿Qué es una «CPU» en Slurm?"
    Cada núcleo físico tiene 2 hilos de hardware, y Slurm cuenta cada hilo como una CPU. Por eso un nodo `CPU` de 128 núcleos aparece con 256 CPUs.

!!! warning "Si pides más de lo que existe, Slurm rechaza el trabajo"
    Un trabajo que pide más tiempo, más nodos o más memoria de los permitidos se rechaza **al enviarlo**, con un mensaje como:

    ```text
    sbatch: error: Batch job submission failed: Requested time limit is invalid (missing or exceeds some limit)
    ```

    Corrige la petición y envíalo de nuevo.

## Comandos básicos

| Comando | Qué hace |
|---|---|
| `sinfo` | estado de particiones y nodos |
| `sbatch script.sh` | envía un trabajo por lotes |
| `squeue -u $USER` | tus trabajos en cola o ejecutándose |
| `scancel <jobid>` | cancela un trabajo |
| `scontrol show job <jobid>` | detalle de un trabajo (por qué espera, dónde corre) |
| `sacct -j <jobid> -o JobID,Elapsed,MaxRSS,ReqMem,State` | qué usó un trabajo que ya terminó |
| `srun --pty bash` | sesión interactiva en un nodo de cómputo |
| `sacctmgr show assoc user=$USER format=account` | tus proyectos |

## Un trabajo típico

```bash
#!/bin/bash
#SBATCH --job-name=prueba
#SBATCH --partition=CPU
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=01:00:00
#SBATCH --output=%x_%j.out

echo "Corriendo en $(hostname) con $SLURM_CPUS_PER_TASK CPUs"
python3 mi_script.py
```

```bash
sbatch prueba.sh          # responde: Submitted batch job 1234
squeue -u $USER           # PD = pendiente, R = ejecutándose
cat prueba_1234.out       # salida, cuando termina
```

## Memoria

- `--mem=16G` pide 16 GB para el trabajo en su nodo.
- `--mem-per-cpu=4G` pide 4 GB por cada CPU.
- Si no pides memoria, recibes la de la tabla de arriba por cada CPU.

**Si tu programa usa más memoria de la que pediste, Slurm lo detiene** y el trabajo termina en estado `OUT_OF_MEMORY`. No hay *swap*: no se puede usar memoria «de más» en disco. Revisa cuánto usó con `sacct` (columna `MaxRSS`) y pide un poco más la próxima vez.

## Un nodo por trabajo

Cada trabajo corre en **un solo nodo**. Chuchunco está pensado para trabajos que caben en un nodo, y un nodo `CPU` ya tiene 256 CPUs y 755 GB de RAM.

Dentro de un nodo puedes usar todo lo que quieras de ese nodo:

- **Multihilo** (OpenMP, NumPy, `multiprocessing`): `--ntasks=1 --cpus-per-task=32`.
- **MPI**: `--nodes=1 --ntasks-per-node=64`.

Un trabajo que pide `--nodes=2` o más se rechaza al enviarlo.

### Si necesitas más de un nodo

Se aprueba **por proyecto**. El o la responsable del proyecto escribe a hpc.fisica@usach.cl explicando qué programa usa, cuántos nodos necesita y por qué no le basta uno. Si se aprueba, los trabajos de ese proyecto pueden usar varios nodos agregando `--qos=multinodo`:

```bash
#SBATCH --nodes=2
#SBATCH --qos=multinodo
```

Sin aprobación, `--qos=multinodo` no funciona.

## Tus proyectos y `-A`

Solo pueden enviar trabajos los integrantes de un **proyecto aprobado**. Cada trabajo se carga a un proyecto.

- Si estás en un solo proyecto, no tienes que hacer nada.
- Si estás en varios, elige con `-A`: `sbatch -A mi-proyecto script.sh` o `#SBATCH -A mi-proyecto`.

Si ves `Invalid account or account/partition combination specified`, tu cuenta no está en ese proyecto (o en ninguno). Revisa con `sacctmgr show assoc user=$USER format=account`.

## ¿Quién va primero? Prioridad y límites

**Prioridad justa (*fair-share*).** Cuando hay cola, van primero los trabajos de los **proyectos que han usado menos el clúster recientemente**. El uso pasado pesa cada vez menos: lo de hace una semana cuenta la mitad que lo de hoy. Además, un trabajo gana prioridad mientras espera. Así nadie acapara el clúster y nadie espera para siempre.

**Límite por persona.** Cada persona puede tener, al mismo tiempo, como máximo:

- **512 CPUs** ejecutándose, y
- **4 GPUs** ejecutándose.

Puedes enviar más trabajos: los que pasen del límite esperan en la cola hasta que termine alguno de los tuyos.

**Pide solo lo que usas.** Un trabajo pequeño y con `--time` ajustado encuentra hueco antes: Slurm puede meterlo en espacios libres mientras esperan trabajos grandes.

## ¿Por qué mi trabajo está pendiente?

`squeue -u $USER` muestra la razón en la columna `NODELIST(REASON)`:

| Razón | Qué significa | Qué hacer |
|---|---|---|
| `Priority` | hay trabajos con más prioridad antes que el tuyo | esperar |
| `Resources` | eres el siguiente, pero aún no hay recursos libres | esperar |
| `QOSMaxCpuPerUserLimit` | ya tienes 512 CPUs en uso | esperar a que terminen tus otros trabajos |
| `QOSMaxGRESPerUser` | ya tienes 4 GPUs en uso | esperar a que terminen tus otros trabajos |
| `ReqNodeNotAvail` | el nodo que pediste no está disponible (por ejemplo, en mantención) | revisar `-p`, `--gres` y `--nodelist`, o esperar |
| `Dependency` | espera a que termine otro trabajo (`--dependency`) | esperar |

Para más detalle: `scontrol show job <jobid>`.

## Sesión interactiva

Para pruebas cortas, compilar o depurar en un nodo de cómputo:

```bash
srun -p CPU --cpus-per-task=4 --mem=8G --time=00:30:00 --pty bash
```

Sal con `exit` para liberar los recursos.

!!! info "No se puede entrar por SSH a los nodos de cómputo"
    Solo el nodo de entrada acepta SSH de usuarios. Para trabajar en un nodo, pide una sesión interactiva con `srun`. Mirar dentro de un trabajo que ya está corriendo (`srun --jobid=<jobid> --pty bash`): por confirmar.

## Opciones `#SBATCH` más usadas

| Opción | Significado |
|---|---|
| `--partition=CPU` | partición |
| `--ntasks=64` | número de procesos (MPI) |
| `--cpus-per-task=8` | CPUs por proceso (OpenMP, Python multiproceso) |
| `--mem=32G` | memoria del trabajo |
| `--gres=gpu:rtx6000ada:1` | GPUs (ver [GPUs](gpu.md)) |
| `--time=1-12:00:00` | tiempo máximo (días-hh:mm:ss), hasta 7 días |
| `--array=1-100` | arreglo de trabajos (ver [Ejemplos](ejemplos.md#arreglo-de-trabajos-barrido-de-parametros)) |
| `-A mi-proyecto` | proyecto al que se carga el trabajo |
| `--output=%x_%j.out` | archivo de salida (`%x` nombre, `%j` número del trabajo) |

!!! note "Sin avisos por correo"
    Por ahora el clúster **no envía correos**: `--mail-type` y `--mail-user` no hacen nada. Revisa tus trabajos con `squeue` y `sacct`.

Más ejemplos en [Ejemplos de trabajos](ejemplos.md).
