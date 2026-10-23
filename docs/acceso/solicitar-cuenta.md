# Solicitar una cuenta

Pueden solicitar cuenta académicos/as, investigadores/as y estudiantes de la USACH, y colaboradores externos patrocinados por un/a académico/a USACH.

## Pasos

1. **Completa el formulario de solicitud de acceso:** {{ formulario-enlace: unirse | acceso }}  
   Si eres estudiante, indica a tu académico/a patrocinador/a. Te pediremos una breve descripción del proyecto, el tipo de recursos (CPU/GPU), el almacenamiento estimado y el software que necesitas.
2. **Genera una llave SSH** (el acceso con contraseña está deshabilitado) — ver [Conectarse por SSH](conectarse.md#1-genera-tu-llave-ssh).
3. **Envía solo tu llave pública** (el archivo que termina en `.pub`) a **hpc.fisica@usach.cl**.
4. **Lee y acepta las [reglas de uso](reglas.md).**

{{ formulario: unirse | acceso }}

Cuando la cuenta esté creada te avisaremos por correo. Tu nombre de usuario será, normalmente, la parte de tu correo USACH antes de la `@` (por ejemplo `nombre.apellido`).

!!! danger "Nunca envíes tu llave privada"
    La llave privada (`id_ed25519`, sin `.pub`) es como una contraseña: no sale de tu computador.

## Usuarios externos

Los colaboradores de otras instituciones necesitan además una **cuenta VPN USACH**, que gestiona la Dirección de Informática a solicitud del equipo C3P. Indícalo en el formulario.
