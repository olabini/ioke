use("dutch")

Rekening = Oorsprong bootsNa doe(
  maakOver = methode(bedrag, van: zelf, naar:,
    van balans -= bedrag
    naar balans += bedrag
  )
 
  schrijf = methode(
    "<Rekening naam: #{naam} balans: #{balans}>" schrijfln
  )
)
 
Piet = Rekening met(naam: "Piet", balans: 142.0)
Marie = Rekening met(naam: "Marie", balans: 45.7)
 
Rekening maakOver(23.0, van: Piet, naar: Marie)
Rekening maakOver(10.0, naar: Piet, van: Marie)
Marie maakOver(57.4, naar: Piet)
 
Piet schrijf
Marie schrijf
