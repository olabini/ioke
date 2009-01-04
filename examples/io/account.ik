Account = Origin mimic
Account balance = 0.0
Account deposit = method(v, self balance = self balance + v)
Account show = method("Account balance: $#{balance}" println)

"Inital: " print
Account show

"Depositing $10" println
Account deposit(10.0)

"Final: " print
Account show
