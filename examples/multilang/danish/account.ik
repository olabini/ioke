
use("danish")
 
Konto = Oprindelse efterlign gør(
  overfør = metode(sum, fra: selv, til:,
    fra saldo -= sum
    til saldo += sum
  )
 
  udskriv = metode(
    "<Konto navn: #{navn} saldo: #{saldo}>" udskrivLinje
  )
)
 
Anders = Konto med(navn: "Anders", saldo: 142.0)
Bjørn = Konto med(navn: "Bjørn", saldo: 45.7)
 
Konto overfør(23.0, fra: Anders, til: Bjørn)
Konto overfør(10.0, til: Anders, fra: Bjørn)
Bjørn overfør(57.4, til: Anders)
 
Anders udskriv
Bjørn udskriv
