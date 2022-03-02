variable "goal_atack" {
  description = "Дай IP ADDRES цих ублюдків (наприклад Tinkoff: 178.248.236.218)"
  type        = string
}

variable "port_atack" {
  description = "PORT по якому відправити груз (наприклад 80)"
  type        = number
}

variable "kozaks" {
  description = "Скільки козаків пустити вбій(к-сть інстансів)"
  type        = number
}
