

  
import(:javax:swing, :JFrame, :JButton)
import java:awt:GridLayout

button = JButton new("Press me!") do(
  addActionListener(fn(e, button text = "Hello from Ioke")))

JFrame new("My Frame") do(
  layout = GridLayout new(2, 2, 3, 3)
  add(button)
  setSize(300, 80)
  visible = true)
