# Reglas de uso

Resumen de la [política de uso de HPC-RF](https://fisica.usach.cl/es/plataforma-de-investigacion-hpc). Al usar el clúster aceptas estas condiciones.

!!! warning "Operación beta: úsalo bajo tu propio riesgo"
    Chuchunco está en **operación beta**. Puedes usarlo, pero las reglas y los límites pueden cambiar con poco aviso, y **no hay respaldo** de `/home` ni de `/data`. Guarda tu propia copia de los resultados importantes.

1. **No ejecutes cálculos en el nodo de entrada.** El *head node* es para editar, compilar, mover archivos y enviar trabajos. Todo cálculo va por Slurm (`sbatch` o `srun`). Los procesos pesados en el nodo de entrada pueden ser terminados sin aviso.
2. **Pide solo lo que usas.** Solicita los núcleos, memoria, GPUs y tiempo que tu trabajo realmente necesita: el clúster es compartido. Los límites (7 días por trabajo, un nodo por trabajo, 512 CPUs y 4 GPUs en uso por persona) están en [Slurm: colas y límites](../uso/slurm.md).
3. **Las cuentas son personales.** No compartas tu cuenta ni tu llave.
4. **Cuentas con vigencia de un año**, renovables mientras el proyecto siga activo.
5. **Tus datos son tu responsabilidad.** No hay respaldo de `/home` ni de `/data`: si borras o pierdes un archivo, no se puede recuperar. Mantén una copia de lo importante fuera del clúster (ver [Almacenamiento](../uso/almacenamiento.md)).
6. **Uso académico.** Servicios a terceros o uso comercial requieren un acuerdo previo con C3P.
7. **Agradecimientos.** Toda tesis, paper o presentación que use el clúster debe incluir el [texto de agradecimiento](../agradecimientos.md) y registrarse en el formulario de productos.

## Cuando dejas el clúster

Si ya no participas en ningún proyecto activo (porque te vas o porque tu proyecto terminó):

- **Desde ese día** tu cuenta queda bloqueada: ya no puedes entrar. Los trabajos que estaban corriendo terminan normalmente y tus archivos quedan donde estaban.
- **A los 6 meses** tu carpeta *home* se archiva y se borra del clúster. Antes de esa fecha te avisamos por correo.
- **El archivo se guarda 18 meses más** (24 meses después del bloqueo) y luego se borra.

Antes de que se archive tu carpeta puedes pedir acceso temporal para copiar tus datos, o que reactivemos tu cuenta. Si el almacenamiento se llena, estos plazos pueden acortarse.

Copia tus resultados antes de irte, y escribe a hpc.fisica@usach.cl si necesitas volver a entrar.
