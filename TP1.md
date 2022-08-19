# TP1: Memoria virtual en JOS

<<<<<<< HEAD
## boot_alloc_pos

a))

### Un cálculo manual de la primera dirección de memoria que devolverá boot_alloc() tras el arranque. Se puede calcular a partir del binario compilado (obj/kern/kernel), usando los comandos readelf y/o nm y operaciones matemáticas.

Rta:
Al no haber nextfree, nextfree apunta a la página siguiente al fin del kernel.
=======
boot_alloc_pos
--------------
>>>>>>> catedra/tp4

Al correr:


readelf -s obj/kern/kernel

y buscar "end" en la tabla obtenemos:

110: f0118950 0 NOTYPE GLOBAL DEFAULT 6 end

Cálculo manual de lo que devolverá boot alloc: <br>
End = f0118950 = 4027681104 bytes <br>
Cada página ocupa 4096 <br>
Cuando boot_alloc hace ROUNDUP(4027681104, 4096): <br>
Manualmente cálculo lo que le falta para ser múltiplo de 4096: 4096 - (4027681104 % 4096) = 1712 <br>
Entonces el múltiplo más cercano es: 4027681104 + 1712 = 4027682816 = f0119000 <br>

b)

### Una sesión de GDB en la que, poniendo un breakpoint en la función boot_alloc(), se muestre el valor devuelto en esa primera llamada, usando el comando GDB finish.

Rta:

<<<<<<< HEAD
```
(gdb) break boot_alloc
Breakpoint 1 at 0xf0100a55: file kern/pmap.c, line 89.
(gdb) c
Continuing.
The target architecture is assumed to be i386
=> 0xf0100a55 <boot_alloc>:	push   %ebp

Breakpoint 1, boot_alloc (n=4096) at kern/pmap.c:89
89	{
(gdb) finish
Run till exit from #0  boot_alloc (n=4096) at kern/pmap.c:89
=> 0xf010260f <mem_init+26>:	mov    %eax,0xf0118948
mem_init () at kern/pmap.c:149
149		kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
Value returned is $1 = (void *) 0xf0119000

```

Ver que resulta en la misma dirección que la calculada en el punto a).

...

## map_region_large

### 1. Modificar la función boot_map_region() para que use page directory entries de 4 MiB cuando sea apropiado. (En particular, sólo se pueden usar en direcciones alineadas a 22 bits) ¿Cuánta memoria se ahorró de este modo? (en KiB)

### 2. ¿Es una cantidad fija, o depende de la memoria física de la computadora?

Respuestas:

1. Por cada large page que se utiliza (cada una ocupa 4 MiB) se estan ahorrando 1024 page tables (cada una ocupa 4 KiB), por lo tanto nos ahorramos 4096 KiB por cada large page.
2. Es siempre lo mismo ya que JOS usa siempre la misma cantidad de memoria para la tablas (4 KiB) independientemente de la arquitectura física de la computadora.

...
=======
map_region_large
----------------
=======
map_region_large
----------------

...

>>>>>>> catedra/tp4
