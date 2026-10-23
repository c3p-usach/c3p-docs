# Preguntas frecuentes

??? question "Mi conexión SSH se queda esperando y nunca pide la frase de paso"
    Es un problema de red: solo se puede entrar desde la red cableada USACH o por VPN. Conéctate a la VPN y prueba de nuevo. Ver [Conectarse](acceso/conectarse.md#si-la-conexion-se-queda-pegada).

??? question "Me dice `Permission denied (publickey)`"
    El servidor no reconoce tu llave. Revisa que enviaste el archivo `.pub` correcto y que usas el usuario correcto. Prueba `ssh -i ~/.ssh/id_ed25519 nombre.apellido@158.170.68.170`.

??? question "Mi trabajo lleva mucho tiempo en estado `PD` (pendiente)"
    Mira la razón en la columna `NODELIST(REASON)` de `squeue -u $USER`:

    - `Resources`: no hay recursos libres ahora; espera.
    - `Priority`: hay otros trabajos antes que el tuyo.
    - `ReqNodeNotAvail`: pediste algo que no existe o un nodo en mantención (revisa la partición, `--gres` y `--mem`).

??? question "Mi trabajo terminó con `OUT_OF_MEMORY` o se cayó sin aviso"
    Pide más memoria con `--mem`. Revisa cuánto usó con `seff <jobid>`.

??? question "¿Puedo instalar software?"
    Sí, en tu `/home` o `/data` (pip/conda en un entorno propio, compilar en tu carpeta) o, mejor, usando [contenedores](uso/contenedores.md). No tienes permisos de administrador (`sudo`).

??? question "¿Cómo uso Python con mis propias librerías?"
    Opción 1: un contenedor (`--container-image=python:3.12`) e instalar con `pip install --user`. Opción 2: Miniforge/conda en tu `/home`. Evita instalar entornos enormes en `/home`; usa `/data`.

??? question "¿Puedo usar Jupyter?"
    Por confirmar. Mientras tanto, trabaja con scripts y `sbatch`.

??? question "¿Hay cola o límites por usuario?"
    Por confirmar. Por ahora pedimos usar los recursos con criterio (ver [Reglas de uso](acceso/reglas.md)).
