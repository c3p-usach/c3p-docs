# Contribuir a Chuchunco

Chuchunco crece con los aportes de los proyectos que lo usan. Hay dos formas de contribuir: aportar a la **infraestructura común**, que beneficia a todos, o aportar un **nodo de cómputo** para tu grupo. Antes de cotizar, escríbenos a hpc.fisica@usach.cl.

## Aportes para la infraestructura común

En orden de prioridad:

1. **Almacenamiento.** Discos duros para el tercer servidor de almacenamiento, del mismo modelo que los actuales: **Seagate Exos X20, 20 TB (ST20000NM002D)**. Faltan 10. Con ellos, los tres servidores de almacenamiento quedan con 24 discos cada uno y el espacio utilizable sube de unos 245 TB a unos 420 TB. Como cada dato se guarda en los tres servidores, el espacio utilizable lo limita el servidor más pequeño. Cualquier cantidad de discos ayuda.
2. **Un cuarto servidor de almacenamiento**, para tener más espacio y más tolerancia a fallas.
3. **Un switch de red para un nuevo rack** (alrededor de US$ 2.500), cuando se sumen más máquinas de cómputo.

**El almacenamiento es el aporte más necesario:** cada máquina que se suma para calcular también trae más datos.

## Aportar un nodo de cómputo

Un grupo de investigación puede comprar una máquina que se suma al clúster.

- La máquina queda **disponible para todos**, y el grupo tiene **prioridad** en ella: sus trabajos van primero en esa máquina.
- La máquina conserva **su propia garantía**. Sumarla no afecta a las demás.
- Hay espacio físico para varias máquinas más.

### Pasos

1. Escribe a hpc.fisica@usach.cl **antes de pedir cotizaciones**.
2. Revisamos la cotización con el proveedor, para que la máquina sea compatible con el clúster.
3. El grupo hace la compra.
4. Los administradores instalan la máquina en el centro de datos de la universidad y la suman al clúster.

### Recomendaciones

En este orden:

1. **Idealmente, el mismo modelo que una máquina que ya tenemos.** Nodos CPU: ASUS RS700A-E12-RS4U con 2× AMD EPYC 9554. Nodos GPU: con 4× NVIDIA RTX 6000 Ada. Una máquina idéntica se suma a una partición existente y funciona exactamente igual que las demás.
2. **Procesadores AMD EPYC de la generación actual, no Intel.** Todo Chuchunco es AMD: con familias de procesadores distintas, un programa compilado en una puede comportarse distinto en la otra, y la máquina necesitaría una partición aparte.
3. **GPUs NVIDIA, de preferencia.** La mayoría del software científico y de IA está hecho para CUDA. AMD Instinct solo si el software del grupo funciona con ROCm.
4. **Servidor de rack** (*rackmount*), con **fuentes de poder redundantes**, **administración remota** (BMC/IPMI) y **dos SSD** para el sistema operativo. Las tarjetas de red se definen con nosotros y el proveedor en cada cotización: deben conectarse a la red de 10 GbE y a la red de almacenamiento del clúster.
5. **Si tu proyecto va a generar muchos datos**, considera incluir en la misma compra discos para el almacenamiento común (ver [arriba](#aportes-para-la-infraestructura-comun)).

Las reglas exactas para las máquinas aportadas (detalles de la prioridad, por cuánto tiempo, fin de vida útil): por confirmar.

## Valorización de servicios

Para postular a fondos, puedes pedir una carta que indique cuánto aporta la universidad cuando tu proyecto usa Chuchunco. Ver [Valorización de servicios](valorizacion.md).
