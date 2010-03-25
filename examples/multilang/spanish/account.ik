use("spanish")

Cuenta = Origen imitación haciendo(

  transfiere = método(cantidad, de: mi, a:,
    de saldo -= cantidad
    a saldo += cantidad
  )

  imprime = método(
    "<Cuenta nombre: #{nombre} saldo: #{saldo}>" imprimeLinea
  )
  
)

Víctor = Cuenta con(nombre: "Víctor", saldo: 142.0)
Hugo = Cuenta con(nombre: "Hugo", saldo: 45.7)

Cuenta transfiere(23.0, de: Víctor, a: Hugo)
Cuenta transfiere(10.0, a: Víctor, de: Hugo)

Hugo transfiere(57.4, a: Víctor)

Víctor imprime
Hugo imprime
