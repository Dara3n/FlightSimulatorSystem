
#!/bin/bash

# El programa a ejecutar
PROGRAM="/usr/local/tsim/tsim-erc32 main"

# Ejecutar el programa y procesar su salida línea por línea
echo -e "\033c" > /dev/pts/1
echo -e "\033c" > /dev/pts/2
$PROGRAM | while IFS= read -r line; do
  if echo "$line" | grep -q "&"; then
      # Limpiar el tty1 si la línea contiene un $
      clear > /dev/pts/1
  else
    if echo "$line" | grep -q "#"; then
        # Volcar al tty1 si la línea contiene un #
        echo "$line" > /dev/pts/1
    else
      if echo "$line" | grep -q "%"; then
        # Volcar al tty2 si la línea contiene un %
        echo "$line" > /dev/pts/2
      else      
        # Volcar al tty0 si la línea no contiene ni # ni % 
        echo "$line" > /dev/pts/0
      fi
    fi
  fi
done
