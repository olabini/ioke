use("swedish")

Konto = Ursprung härma gör(
  skicka = metod(summa, från: själv, till:,
    från saldo -= summa
    till saldo += summa
  )

  skrivUt = metod(
    "<Konto namn: #{namn} saldo: #{saldo}>" skrivUtRad
  )
)

Anders = Konto med(namn: "Anders", saldo: 142.0)
Björn  = Konto med(namn: "Björn", saldo: 45.7)

Konto  skicka(23.0, från: Anders, till: Björn)
Konto  skicka(10.0, till: Anders, från: Björn)
Björn  skicka(57.4, till: Anders)

Anders skrivUt
Björn  skrivUt
