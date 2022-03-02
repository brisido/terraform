locals {
  sqs_queue = {
    sqs1 = {
      name = "fila-teste-a_queue"
    }
    sqs1fifo = {
      name       = "fila-teste-a_queue.fifo"
      fifo_queue = true
    }
    sqs2 = {
      name                       = "fila-teste-b_queue"
      delay_seconds              = 5
      max_message_size           = 131072
      message_retention_seconds  = 1440
      receive_wait_time_seconds  = 2
      visibility_timeout_seconds = 15
    }
    sqs3 = {
      name = "fila-teste-c_queue"
      dlq = {
        enable = true
      }
    }
    sqs4 = {
      name                       = "fila-teste-d_queue"
      delay_seconds              = 5
      max_message_size           = 131072
      message_retention_seconds  = 1440
      receive_wait_time_seconds  = 2
      visibility_timeout_seconds = 15
      dlq = {
        enable                     = true
        retries                    = 10
        delay_seconds              = 1
        max_message_size           = 196608
        message_retention_seconds  = 86400
        receive_wait_time_seconds  = 5
        visibility_timeout_seconds = 25
      }
    }
    sqs5 = {
      name                       = "fila-teste-e_queue"
      delay_seconds              = 5
      max_message_size           = 131072
      message_retention_seconds  = 1440
      receive_wait_time_seconds  = 2
      visibility_timeout_seconds = 15
      dlq = {
        enable                     = true
        retries                    = 10
        delay_seconds              = 1
        max_message_size           = 196608
        message_retention_seconds  = 86400
        receive_wait_time_seconds  = 5
        visibility_timeout_seconds = 25
      }
    #   subscription = {
    #     protocol = "sqs"
    #     name = "nome_do_topico"
    #   }
    }
  }
}