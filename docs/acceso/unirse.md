# Unirse a un proyecto

!!! abstract "In English: for external collaborators"
    To get an account on Chuchunco you join an existing project led by a USACH academic. Ask them for the **project code or invitation link**, create an SSH key ([instructions](conectarse.md#1-genera-tu-llave-ssh)), and fill in the form below, pasting **only your public key** (the `.pub` file). You will get an email to confirm your address; then the project lead approves you, and then we do. We will request a USACH VPN account for you, which you need to connect from outside the university.

## Antes de empezar

- **El código del proyecto o el enlace de invitación.** Pídeselo al académico/a responsable (*PI*) del proyecto. Si tu académico/a aún no tiene proyecto, puede [solicitar uno](solicitar-proyecto.md).
- **Una llave SSH.** El acceso con contraseña está deshabilitado. Genera tu llave siguiendo [Conectarse por SSH](conectarse.md#1-genera-tu-llave-ssh) y copia el contenido de tu **llave pública** (el archivo que termina en `.pub`) en el formulario.

!!! danger "Nunca envíes tu llave privada"
    La llave privada (`id_ed25519`, sin `.pub`) es como una contraseña: no sale de tu computador. En el formulario va solo la llave pública.

## Formulario

**{{ formulario-enlace: unirse }}**

{{ formulario: unirse }}

## ¿Qué pasa después?

1. Te llega un correo para **confirmar tu dirección**.
2. El académico/a responsable del proyecto **aprueba tu ingreso**.
3. **Nosotros** creamos tu cuenta y te avisamos por correo.

Tu nombre de usuario será la parte de tu correo USACH antes de la `@` (por ejemplo `nombre.apellido`). Antes de conectarte, lee las [reglas de uso](reglas.md).

## Usuarios externos

Si eres de otra institución, necesitas además una **cuenta VPN USACH** para conectarte desde fuera de la universidad. La solicitamos nosotros por ti cuando se aprueba tu ingreso.

## Cambiar tu llave o unirte a otro proyecto

Usa este mismo formulario para **cambiar tu llave SSH** (por ejemplo, si cambiaste de computador) o para **unirte a otro proyecto**. Tu cuenta sigue siendo la misma.
