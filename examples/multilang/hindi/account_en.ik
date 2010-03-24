


Account = Origin mimic do(
  transfer = method(amount, from: self, to:,
    from balance -= amount
    to balance += amount
  )

  print = method(
    "<Account name: #{name} balance: #{balance}>" println
  )
)

Sriram = Account with(name: "Sriram", balance: 142.0)
Gurmeet = Account with(name: "Gurmeet", balance: 45.7)

Account transfer(23.0, from: Sriram, to: Gurmeet)
Account transfer(10.0, to: Sriram, from: Gurmeet)
Gurmeet  transfer(57.4, to: Sriram)

Sriram   print
Gurmeet  print
