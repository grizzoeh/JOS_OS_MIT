# TP2: Procesos de usuario

## env_alloc <br>

## 1. ¿Qué identificadores se asignan a los primeros 5 procesos creados? (Usar base hexadecimal) <br>

Los envs se inicializan con env_id 0

```
generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);

```

Al hacer 1<<12 = 4096. Luego 4096 & -1024 = 4096. El generation de estos primeros procesos será 4096
Entonces el primer id será 4096 = 0x1000 hexa

```
e->env_id = generation | (e - envs);
```

Para el primer proceso e - envs será 0.

Entonces el primer id será 4096 = 0x1000 hexa
El segundo id será 4097 = 0x1001
El tercer id será 4098 = 0x1002
El cuarto id será 4099 = 0x1003
el quinto id será 4100 = 0x1004

## 2.Supongamos que al arrancar el kernel se lanzan NENV procesos a ejecución. A continuación, se destruye el proceso asociado a envs[630] y se lanza un proceso que cada segundo, muere y se vuelve a lanzar (se destruye, y se vuelve a crear). ¿Qué identificadores tendrán esos procesos en las primeras cinco ejecuciones?

El primer proceso que está en env[630] tiene como id 0x1276 (4726 en decimal que viene de 4096+630).
Cuando se genera un nuevo proceso, uso el env_id del anterior para el generation.
Al destruirlo, muere y se vuelve a lanzar otro proceso, aumentando en 4096 posiciones decimales.
Por lo que el id del segundo será: 8822 = 0x2276
id del tercero será: 12918 = 0x3276
id del cuarto será: 17014 = 0x4276
id del quinto será: 21110 = 0x5276
...

## env_pop_tf

## Tarea: env_pop_tf : La función env_pop_tf() ya implementada es en JOS el último paso de un context switch a modo usuario. Antes de implementar env_run(), responder a las siguientes preguntas:

## 1. Dada la secuencia de instrucciones assembly en la función, describir qué contiene durante su ejecución:

### El tope de la pila justo antes popal:

La función env_pop_tf recibe un struct Trapframe por parámetro, el tope de la pila contendrá el primer elemento del Trapframe.
### El tope de la pila justo antes iret

Luego de hacer popl %%es y popl %%ds que popean del stack el tf_es y tf_ds respectivamente. Justo
antes del iret el tope de la pila tendra el tf_eip del TrapFrame.

### El tercer elemento de la pila justo antes de iret

Por lo tanto el tercer elemento de la pila justo antes del iret será tf_eflags.

## 2. En la documentación de iret en [IA32-2A] se dice:

## If the return is to another privilege level, the IRET instruction also pops the stack pointer and SS from the stack, before resuming program execution.

## ¿Cómo determina la CPU (en x86) si hay un cambio de ring (nivel de privilegio)? Ayuda: Responder antes en qué lugar exacto guarda x86 el nivel de privilegio actual. ¿Cuántos bits almacenan ese privilegio?

El privilegio actual es el CPL Current Privilege Level (almacenado en 2 bits), se guarda en el registro cs (sus bits
menos significativos), para determinar un cambio en ring se compara el CPL con el DPL Descriptor Privilege Level.

...

## gdb_hello

## Tarea: gdb_hello :Arrancar el programa hello.c bajo GDB. Se pide mostrar una sesión de GDB con los siguientes pasos:

### 1. Poner un breakpoint en env_pop_tf() y continuar la ejecución hasta allí.

```
(gdb) b env_pop_tf
Breakpoint 1 at 0xf0102f53: file kern/env.c, line 477.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf0102f53 <env_pop_tf>: endbr32

Breakpoint 1, env_pop_tf (tf=0xf01c8000) at kern/env.c:477
477 {
```

### 2.En QEMU, entrar en modo monitor (Ctrl-a c), y mostrar las cinco primeras líneas del comando info registers.

```
(qemu) info registers
EAX=003bc000 EBX=00010094 ECX=f03bc000 EDX=0000020d
ESI=00010094 EDI=00000000 EBP=f0119fd8 ESP=f0119fbc
EIP=f0102f53 EFL=00000092 [--S-A--] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0010 00000000 ffffffff 00cf9300 DPL=0 DS [-WA]
CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]
```

#### 3.De vuelta a GDB, imprimir el valor del argumento tf:

```
(gdb) p tf
$1 = (struct Trapframe \*) 0xf01c8000

```

### 4.Imprimir, con x/Nx tf tantos enteros como haya en el struct Trapframe donde N = sizeof(Trapframe) / sizeof(int).

```
(gdb) print sizeof(struct Trapframe) / sizeof(int)
$2 = 17
(gdb) x/17x tf
0xf01c8000: 0x00000000 0x00000000 0x00000000 0x00000000
0xf01c8010: 0x00000000 0x00000000 0x00000000 0x00000000
0xf01c8020: 0x00000023 0x00000023 0x00000000 0x00000000
0xf01c8030: 0x00800020 0x0000001b 0x00000000 0xeebfe000
0xf01c8040: 0x00000023
```

### 5.Avanzar hasta justo después del movl ...,%esp, usando si M para ejecutar tantas instrucciones como sea necesario en un solo paso:

```
(gdb) disas
Dump of assembler code for function env_pop_tf:
=> 0xf0102f53 <+0>: endbr32
0xf0102f57 <+4>: push %ebp
0xf0102f58 <+5>: mov %esp,%ebp
0xf0102f5a <+7>: sub $0xc,%esp
0xf0102f5d <+10>: mov 0x8(%ebp),%esp
0xf0102f60 <+13>: popa
 0xf0102f61 <+14>: pop %es
0xf0102f62 <+15>: pop %ds
0xf0102f63 <+16>: add $0x8,%esp
0xf0102f66 <+19>: iret
 0xf0102f67 <+20>: push $0xf01059f9
0xf0102f6c <+25>: push $0x1e7
0xf0102f71 <+30>: push $0xf010598a
0xf0102f76 <+35>: call 0xf01000ad <\_panic>
End of assembler dump.
(gdb) si 5
=> 0xf0102f60 <env_pop_tf+13>: popa
0xf0102f60 in env_pop_tf (tf=0x0) at kern/env.c:478
478 asm volatile("\tmovl %0,%%esp\n"

```

### 6.Comprobar, con x/Nx $sp que los contenidos son los mismos que tf (donde N es el tamaño de tf).

```
(gdb) x/17x $sp
0xf01c8000: 0x00000000 0x00000000 0x00000000 0x00000000
0xf01c8010: 0x00000000 0x00000000 0x00000000 0x00000000
0xf01c8020: 0x00000023 0x00000023 0x00000000 0x00000000
0xf01c8030: 0x00800020 0x0000001b 0x00000000 0xeebfe000
0xf01c8040: 0x00000023

```

### Describir cada uno de los valores. Para los valores no nulos, se debe indicar dónde se configuró inicialmente el valor, y qué representa.

Los primeros 8 (0x00000000), son los registros de PushRegs.

- tf_es (extra_segment) tiene el valor 0x00000023, configurado en env_alloc(): e->env_tf.tf_es = GD_UD | 3;

- tf_ds (data segment) tiene el valor 0x00000023, configurado en env_alloc(): e->env_tf.tf_ds = GD_UD | 3;

- tf_ss (stack segment) 0x00000023, configurado en env_alloc(): e->env_tf.tf_ss = GD_UD | 3;

- tf_eip tiene el valor 0x00800020, configurado en load_icode(). Es el entry point del elf.

- tf_cs (code segment) tiene el valor 0x0000001b, configurado en env_alloc(): e->env_tf.tf_cs = GD_UT | 3;

- tf_esp (stack pointer) tiene el valor 0xeebfe000, configurado en env_alloc(): e->env_tf.tf_esp = USTACKTOP;

- tf_trapno tiene el valor 0x00000000
- tf_err tiene el valor 0x00000000
- tf_eflags tiene el valor 0x00000000

### 8.Continuar hasta la instrucción iret, sin llegar a ejecutarla. Mostrar en este punto, de nuevo, las cinco primeras líneas de info registers en el monitor de QEMU. Explicar los cambios producidos.

```
(gdb) disas
Dump of assembler code for function env_pop_tf:
0xf0102f53 <+0>: endbr32
0xf0102f57 <+4>: push %ebp
0xf0102f58 <+5>: mov %esp,%ebp
0xf0102f5a <+7>: sub $0xc,%esp
0xf0102f5d <+10>: mov 0x8(%ebp),%esp
=> 0xf0102f60 <+13>: popa
 0xf0102f61 <+14>: pop %es
0xf0102f62 <+15>: pop %ds
0xf0102f63 <+16>: add $0x8,%esp
0xf0102f66 <+19>: iret
 0xf0102f67 <+20>: push $0xf01059f9
0xf0102f6c <+25>: push $0x1e7
0xf0102f71 <+30>: push $0xf010598a
0xf0102f76 <+35>: call 0xf01000ad <\_panic>
End of assembler dump.
(gdb) si 4
=> 0xf0102f66 <env_pop_tf+19>: iret
0xf0102f66 478 asm volatile("\tmovl %0,%%esp\n"
(gdb) disas
Dump of assembler code for function env_pop_tf:
0xf0102f53 <+0>: endbr32
0xf0102f57 <+4>: push %ebp
0xf0102f58 <+5>: mov %esp,%ebp
0xf0102f5a <+7>: sub $0xc,%esp
0xf0102f5d <+10>: mov 0x8(%ebp),%esp
0xf0102f60 <+13>: popa
 0xf0102f61 <+14>: pop %es
0xf0102f62 <+15>: pop %ds
0xf0102f63 <+16>: add $0x8,%esp
=> 0xf0102f66 <+19>: iret
 0xf0102f67 <+20>: push $0xf01059f9
0xf0102f6c <+25>: push $0x1e7
0xf0102f71 <+30>: push $0xf010598a
0xf0102f76 <+35>: call 0xf01000ad <\_panic>
End of assembler dump.

```

```
EAX=00000000 EBX=00000000 ECX=00000000 EDX=00000000
ESI=00000000 EDI=00000000 EBP=00000000 ESP=f01c8030
EIP=f0102f66 EFL=00000096 [--S-AP-] CPL=0 II=0 A20=1 SMM=0 HLT=0
ES =0023 00000000 ffffffff 00cff300 DPL=3 DS [-WA]
CS =0008 00000000 ffffffff 00cf9a00 DPL=0 CS32 [-R-]
```

Antes del iret se ejecutaron popal, pop % es y pop %ds.

Por popal se actualizaron EAX=00000000 EBX=00000000 ECX=00000000 EDX=00000000
ESI=00000000 EDI=00000000 EBP=00000000 con los valores del trapframe (que estaban en 0 por el punto anterior).

pop % es y pop %ds actualizaron los valores de ES Y DS, con los del trapframe. Sus dpl pasan a 3 (usuario).

El dpl de CS sigue en 0 (kernel).

### 9. Ejecutar la instrucción iret. En ese momento se ha realizado el cambio de contexto y los símbolos del kernel ya no son válidos. imprimir el valor del contador de programa con p $pc o p $eip.

```
(gdb) p $pc
$4 = (void (\*)()) 0x800020
```

### Cargar los símbolos de hello con el comando add-symbol-file.

```
(gdb) add-symbol-file obj/user/hello 0x800020
add symbol table from file "obj/user/hello" at
.text_addr = 0x800020
(y or n) y
Reading symbols from obj/user/hello...
```

### Volver a imprimir el valor del contador de programa

```
(gdb) p $pc
$5 = (void (\*)()) 0x800020 <\_start>
```

### Mostrar una última vez la salida de info registers en QEMU, y explicar los cambios producidos.

```
(qemu) info registers
EAX=00000000 EBX=00000000 ECX=00000000 EDX=00000000
ESI=00000000 EDI=00000000 EBP=00000000 ESP=eebfe000
EIP=00800020 EFL=00000002 [-------] CPL=3 II=0 A20=1 SMM=0 HLT=0
ES =0023 00000000 ffffffff 00cff300 DPL=3 DS [-WA]
CS =001b 00000000 ffffffff 00cffa00 DPL=3 CS32 [-R-]
```

Al ejecutar iret, los registros siguen teniendo el valor del trapframe, ahora el DPL de CS pasa a ser 3 (usuario).

### 10.Poner un breakpoint temporal (tbreak, se aplica una sola vez) en la función syscall() y explicar qué ocurre justo tras ejecutar la instrucción int $0x30. Usar, de ser necesario, el monitor de QEMU.

```
=> 0xf01038b8 <F_SYSCALL_G+2>: push $0x30
0xf01038b8 in F_SYSCALL_G () at kern/trapentry.S:70
70 TRAPHANDLER_NOEC(F_SYSCALL_G, T_SYSCALL)

```

int $0x30 intenta ejecutar la syscall pero se genera una interrupción del kernel (definida en trapentry.S)

## kern_idt <br>

## Leer user/softint.c y ejecutarlo con make run-softint-nox. ¿Qué interrupción trata de generar? ¿Qué interrupción se genera? Si son diferentes a la que invoca el programa… ¿cuál es el mecanismo por el que ocurrió esto, y por qué motivos? ¿Qué modificarían en JOS para cambiar este comportamiento? <br>

Softint intenta generar una interrupción tipo Page Fault. Pero en realidad se genera una interrupción de tipo General Protection.
Ocurre esto ya que el proceso de usuario tenía un bug, lo que generó un page fault. Pero este solo puede ser detectado por el kernel, por ese motivo el kernel elimina el environment, generando un interrupt mediante la General Protection.

Lo que modificariamos en JOS para cambiar este comportamiento es que en vez de matar al proceso de usuario y generar la interrupción page fault desde el ring 0, el kernel le envíe un interrupt al proceso de usuario avisandole que hubo un page fault y que va a matar su proceso, permitiendole al proceso de usuario comunicarle al usuario el error que hubo en su programa, permitiendole comprender mejor el error.

## user_evilhello

## Ejecutar el siguiente programa y describir qué ocurre, respondiendo a las siguientes preguntas.

```
#include <inc/lib.h>

void
umain(int argc, char \**argv)
{
char *entry = (char *) 0xf010000c;
char first = *entry;
sys_cputs(&first, 1);
}

```

## ¿En qué se diferencia el código de la versión en evilhello.c mostrada arriba?

## ¿En qué cambia el comportamiento durante la ejecución?

## ¿Por qué? ¿Cuál es el mecanismo?

## Listar las direcciones de memoria que se acceden en ambos casos, y en qué ring se realizan. ¿Es esto un problema? ¿Por qué?

Código original:

```
void
umain(int argc, char \*_argv)
{
// try to print the kernel entry point as a string! mua ha ha!
sys_cputs((char _) 0xf010000c, 1);
}

```

Código que falla:

```

umain(int argc, char \**argv)
{
char *entry = (char *) 0xf010000c;
char first = *entry;
sys_cputs(&first, 1);
}
```

La diferencia es que en el código de arriba ocurre un Page Fault ya que se intenta
acceder a una dirección de kernel (0xf010000c) estando en el modo usuario (al hacer la desreferencia):

```
char _entry = (char _) 0xf010000c;
char first = \*entry;
```

En cambio, en el código original esto no sucede ya que se hace con la syscall sys_cputs
que utiliza la función user_mem_assert para chequear los accesos permitidos en los diferentes
rangos de memoria. Además el uso de la syscall (enviada por el kernel) permite acceder a direcciones de kernel y por lo tanto verificar si hay errores al intentar acceder a memoria.

En el caso que falla se quiere acceder a:

- 0xf010000c desde ring 3 por lo cual tira error ya que el usuario no tiene los permisos necesarios.

En el original se accede a la misma pero desde el ring 0, usando la syscall sys_cputs por lo cual tendría los permisos necesarios.

...


kern_idt
--------

...


<<<<<<< HEAD
=======
kern_idt
--------

...


>>>>>>> catedra/tp4
user_evilhello
--------------

...

