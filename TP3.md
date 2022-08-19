# TP3: Multitarea con desalojo

## sys_yield

## Leer y estudiar el código del programa user/yield.c. Cambiar la función i386_init() para lanzar tres instancias de dicho programa, y mostrar y explicar la salida de make qemu-nox.

La salida de qemu-nox es:

```

Booting from Hard Disk..6828 decimal is 15254 octal!
Physical memory: 131072K available, base = 640K, extended = 130432K
check_page_free_list() succeeded!
check_page_alloc() succeeded!
check_page() succeeded!
check_kern_pgdir() succeeded!
check_page_free_list() succeeded!
check_page_installed_pgdir() succeeded!
SMP: CPU 0 found 1 CPU(s)
enabled interrupts: 1 2
[00000000] new env 00001000
[00000000] new env 00001001
[00000000] new env 00001002
[00000000] new env 00001003
[00000000] new env 00001004
[00000000] new env 00001005
Hello, I am environment 00001000, cpu 0
Hello, I am environment 00001001, cpu 0
Hello, I am environment 00001002, cpu 0
hello, world
i am environment 00001003
hello, world
i am environment 00001004
[00001004] exiting gracefully
[00001004] free env 00001004
Back in environment 00001000, iteration 0, cpu 0
Back in environment 00001001, iteration 0, cpu 0
Back in environment 00001002, iteration 0, cpu 0
[00001003] exiting gracefully
[00001003] free env 00001003
Back in environment 00001000, iteration 1, cpu 0
Back in environment 00001001, iteration 1, cpu 0
Back in environment 00001002, iteration 1, cpu 0
hello, world
Back in environment 00001000, iteration 2, cpu 0
Back in environment 00001001, iteration 2, cpu 0
Back in environment 00001002, iteration 2, cpu 0
i am environment 00001005
[00001005] exiting gracefully
[00001005] free env 00001005
Back in environment 00001000, iteration 3, cpu 0
Back in environment 00001001, iteration 3, cpu 0
Back in environment 00001002, iteration 3, cpu 0
Back in environment 00001000, iteration 4, cpu 0
All done in environment 00001000.
[00001000] exiting gracefully
[00001000] free env 00001000
Back in environment 00001001, iteration 4, cpu 0
All done in environment 00001001.
[00001001] exiting gracefully
[00001001] free env 00001001
Back in environment 00001002, iteration 4, cpu 0
All done in environment 00001002.
[00001002] exiting gracefully
[00001002] free env 00001002

```

En este ejemplo se puede ver como se va haciendo round robin entre los 3 procesos. En cada iteración se van desalojando secuencialmente.
Comienza 00001000 y cuando finaliza su turno se desaloja, luego por round robin el siguiente enviroment a correr es el 00001001 y luego el 00001002.
Por round robin le toca a 00001000 nuevamente y así se repiten los ciclos hasta que cada enviroment va terminando y finaliza su ejecución.
...

## dumbfork

## Si una página no es modificable en el padre ¿lo es en el hijo? En otras palabras: ¿se preserva, en el hijo, el flag de solo-lectura en las páginas copiadas?

No se preservan los flags de solo lectura, ya que en duppage() (usada en dumbfork) su usan los permisos PTE_P|PTE_U|PTE_W.

## Mostrar, con código en espacio de usuario, cómo podría dumbfork() verificar si una dirección en el padre es de solo lectura, de tal manera que pudiera pasar como tercer parámetro a duppage() un booleano llamado readonly que indicase si la página es modificable o no: Ayuda: usar las variables globales uvpd y/o uvpt.

```
envid_t dumbfork(void) {
    // ...
    for (addr = UTEXT; addr < end; addr += PGSIZE) {
        bool readonly;
        //
        // TAREA: dar valor a la variable readonly

        pte_t pte = uvpt[PGNUM(addr)];
        pde_t pde = uvpd[PDX(addr)];

        readonly = !( (pte & PTE_W) && (pde & PTE_W) );

        duppage(envid, addr, readonly);
    }
```

## Supongamos que se desea actualizar el código de duppage() para tener en cuenta el argumento readonly: si este es verdadero, la página copiada no debe ser modificable en el hijo. Es fácil hacerlo realizando una última llamada a sys_page_map() para eliminar el flag PTE_W en el hijo, cuando corresponda:

```
void duppage(envid_t dstenv, void *addr, bool readonly) {
    // Código original (simplificado): tres llamadas al sistema.
    sys_page_alloc(dstenv, addr, PTE_P | PTE_U | PTE_W);
    sys_page_map(dstenv, addr, 0, UTEMP, PTE_P | PTE_U | PTE_W);

    memmove(UTEMP, addr, PGSIZE);
    sys_page_unmap(0, UTEMP);

    // Código nuevo: una llamada al sistema adicional para solo-lectura.
    if (readonly) {
        sys_page_map(dstenv, addr, dstenv, addr, PTE_P | PTE_U);
    }
}
```

## Esta versión del código, no obstante, incrementa las llamadas al sistema que realiza duppage() de tres, a cuatro. Se pide mostrar una versión en el que se implemente la misma funcionalidad readonly, pero sin usar en ningún caso más de tres llamadas al sistema.

## Ayuda: Leer con atención la documentación de sys_page_map() en kern/syscall.c, en particular donde avisa que se devuelve error:

### if (perm & PTE_W) is not zero, but srcva is read-only in srcenvid’s address space.

```
void
duppage(envid_t dstenv, void *addr, bool readonly)
{
  	int r;

    int perm = PTE_P | PTE_U;

    if (!readonly){
        perm |= PTE_W;
        }


	if ((r = sys_page_alloc(dstenv, addr, perm)) < 0)
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, perm)) < 0)
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
		panic("sys_page_unmap: %e", r);

}


```

...

## ipc_recv

## Un proceso podría intentar enviar el valor númerico -E_INVAL vía ipc_send(). ¿Cómo es posible distinguir si es un error, o no?

```
envid_t src = -1;
int r = ipc_recv(&src, 0, NULL);

if (r < 0)
  if (/* ??? */)
    puts("Hubo error.");
  else
    puts("Valor negativo correcto.")
```

...

Podríamos distingir si es un error incluyendo la siguiente línea en el if (en ipc_rcv):

```
(uintptr_t) dstva < UTOP && (((uintptr_t) dstva) % PGSIZE != 0)
```

En caso de que la misma evalue a true, significará que fue un error. En caso contrario será el mensaje envíado.

...

## sys_ipc_try_send

## Se pide ahora explicar cómo se podría implementar una función sys_ipc_send() (con los mismos parámetros que sys_ipc_try_send()) que sea bloqueante, es decir, que si un proceso A la usa para enviar un mensaje a B, pero B no está esperando un mensaje, el proceso A sea puesto en estado ENV_NOT_RUNNABLE, y despertado una vez B llame a ipc_recv() (cuya firma no debe ser cambiada).

## Es posible que surjan varias alternativas de implementación; para cada una, indicar:

### Qué cambios se necesitan en struct Env para la implementación (campos nuevos, y su tipo; campos cambiados, o eliminados, si los hay)

### Qué asignaciones de campos se harían en sys_ipc_send()

### Qué código se añadiría en sys_ipc_recv()

## ¿Existe posibilidad de deadlock?

## ¿Funciona que varios procesos (A₁, A₂, …) puedan enviar a B, y quedar cada uno bloqueado mientras B no consuma su mensaje? ¿En qué orden despertarían?

...

Para implementar un sys_ipc_try_send bloqueante se necesitará agregar un campo al struct Env, el cual será env_ipv_sending.

En sys_ipc_send se agregaría la siguiente línea:

- env->env_ipc_sending = 1;

Este campo funciona análogamente al env_ipc_recv, pero los valores se setearán al revés.

Además deberíamos modificar la siguiente línea:

- env->env_status = ENV_RUNNABLE
  Resultando:
  -env->env_status = ENV_NOT_RUNNABLE;

Con esto se bloquearía el proceso hasta que se consuma el mensaje.

Además en el sys_ipc_recv deberíamos agregar las siguientes líneas:

- env->env_ipv_sending = 0;

```
  for (int i = 0; i < NENV; i++) {
    if (envs[i]->env_id == env_ipc_from) {
      envs[i]->env_status = ENV_RUNNABLE;
      break;
    }
  }
```

- Existe la posibilidad de deadlock debido a que si un proceso envía un mensaje y el otro no lo consume, el proceso que envía se quedaría bloqueado.

- Funciona debido a que B irá recibiendo los diferentes mensajes en el orden en que el sistema operativo lo decida. En cada uno, el sistema operativo será el encargado de setear el valor del campo env_ipc_from lo cual permitirá saber de que enviroment es el mensaje.

...
