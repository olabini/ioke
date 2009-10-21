Account = Origin mimic do(
  transfer = method(amount, from: self, to:,
    from balance -= amount
    to balance += amount
  )

  print = method(
    "<Account name: #{name} balance: #{balance}>" println
  )
)

Xiao = Account with(name: "Xiao", balance: 142.0)
Jiajun = Account with(name: "Jiajun", balance: 45.7)

Account transfer(23.0, from: Xiao, to: Jiajun)
Account transfer(10.0, to: Xiao, from: Jiajun)
Jiajun  transfer(57.4, to: Xiao)

Xiao   print
Jiajun print
