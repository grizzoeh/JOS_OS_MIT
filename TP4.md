TP4: Sistema de archivos e intérprete de comandos
=================================================

caché de bloques
----------------
## Se recomienda leer la función diskaddr() en el archivo fs/bc.c. Responder:
## ¿Qué es super->s_nblocks?
## ¿Dónde y cómo se configura este bloque especial?
...

Super->s_nblock representa el numero total de bloques en nuestro disco.

Super ss configura en la funcion opendisk del archivo fsformat.c
de esta manera:

super = alloc(BLKSIZE); //aloca memoria del tamaño de un bloque 

super->s_magic = FS_MAGIC; //le asigna el numero magico del sistema de archivos

super->s_nblocks = nblocks; //le asigna la cantidad de bloques que tiene el disco

super->s_root.f_type = FTYPE_DIR; //le asigna el tipo directorio a la root

strcpy(super->s_root.f_name, "/"); //le asigna el nombre a la root
que sera "/"