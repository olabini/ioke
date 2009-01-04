
Account = Origin mimic do(
  balance = 0.0
  deposit = method(v, self balance += v)
  show = method("Account balance: $#{balance}" println)
)

"Inital: " print
Account show

"Depositing $10" println
Account deposit(10.0)

"Final: " print
Account show
