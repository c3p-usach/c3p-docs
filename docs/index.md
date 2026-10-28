# Clúster Chuchunco

<div class="c3p-hero" markdown>
**Chuchunco** es el clúster de cómputo de alto rendimiento (HPC) del Departamento de Física de la Universidad de Santiago de Chile, operado por la plataforma **C3P** (Computación Científica y Procesamiento de Datos).

Financiado por el proyecto FONDEQUIP EQM230160 · abierto a la comunidad de investigación USACH y sus colaboradores.
</div>

!!! warning "Operación beta: úsalo bajo tu propio riesgo"
    Chuchunco ya se puede usar, pero está en **operación beta**:

    - las reglas y los límites **pueden cambiar** mientras ajustamos el servicio;
    - **no hay respaldo** de `/home` ni de `/data`: si se pierde un archivo, no se puede recuperar. **Guarda tu propia copia** de los resultados importantes;
    - las secciones marcadas con **«por confirmar»** aún no están definidas.

## ¿Qué ofrece?

| Recurso | Nodos | Por nodo |
|---|---|---|
| CPU general (`CPU`) | 5 (`cpun1`–`cpun5`) | 2× AMD EPYC 9554 · 128 núcleos · 755 GB RAM |
| Alta memoria (`MEM`) | 1 (`high-ram-n1`) | 2× AMD EPYC 9654 · 192 núcleos · 1,5 TB RAM |
| GPU NVIDIA (`GPU`) | 2 (`gpun2`, `gpun3`) | 4× NVIDIA RTX 6000 Ada (48 GB) · 24 núcleos · 251 GB RAM |
| GPU AMD (`GPU`) | 1 (`gpun1`) | 4× AMD Instinct MI210 (64 GB) · 32 núcleos · 503 GB RAM |
| Almacenamiento | CEPH distribuido, montado en `/data` | ~245 TiB utilizables (1,24 PB brutos, cada dato guardado 3 veces) |

En total: **más de 900 núcleos de CPU, 12 GPUs y más de 6 TB de RAM**, administrados con el gestor de colas **Slurm** y con soporte nativo de contenedores (**Pyxis/Enroot**).

![Arquitectura del clúster](assets/arquitectura-cluster.png)

## Empieza aquí

<div class="grid cards" markdown>

-   :material-account-plus:{ .lg } **1 · Solicita una cuenta**

    ---
    Abre un proyecto o únete a uno.

    [:octicons-arrow-right-24: Solicitar](acceso/solicitar-cuenta.md)

-   :material-console:{ .lg } **2 · Conéctate**

    ---
    SSH desde la red USACH o por VPN.

    [:octicons-arrow-right-24: Conectarse](acceso/conectarse.md)

-   :material-play-circle:{ .lg } **3 · Lanza tu primer trabajo**

    ---
    Tu primer trabajo con Slurm, paso a paso, en 15 minutos.

    [:octicons-arrow-right-24: Primeros pasos](uso/primeros-pasos.md)

-   :material-book-check:{ .lg } **4 · Agradece y registra**

    ---
    Texto de agradecimiento y formulario de productos.

    [:octicons-arrow-right-24: Agradecimientos](agradecimientos.md)

</div>
