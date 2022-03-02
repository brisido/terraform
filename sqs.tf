# CREATE SQS QUEUE RESOURCE
resource "aws_sqs_queue" "queue" {
  for_each                   = local.sqs_queue
  name                       = each.value.name
  fifo_queue                 = try(each.value.fifo_queue, false)
  delay_seconds              = try(each.value.delay_seconds, 0)
  max_message_size           = try(each.value.max_message_size, 262144)
  message_retention_seconds  = try(each.value.message_retention_seconds, 345600)
  receive_wait_time_seconds  = try(each.value.receive_wait_time_seconds, 0)
  visibility_timeout_seconds = try(each.value.visibility_timeout_seconds, 30)
  redrive_policy             = try(each.value.dlq.enable == true ? jsonencode({
                                 deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
                                 maxReceiveCount     = try(each.value.dlq.retries, 5)
                               }) : null, null)
}

# CREATE SQS DLQ RESOURCE
resource "aws_sqs_queue" "dlq" {
  for_each                   = local.sqs_queue
  name                       = replace(each.value.name, "queue", "dlq")
  fifo_queue                 = try(each.value.fifo_queue, false)
  delay_seconds              = try(each.value.dlq.delay_seconds, 0)
  max_message_size           = try(each.value.dlq.max_message_size, 262144)
  message_retention_seconds  = try(each.value.dlq.message_retention_seconds, 1209600)
  receive_wait_time_seconds  = try(each.value.dlq.receive_wait_time_seconds, 0)
  visibility_timeout_seconds = try(each.value.dlq.visibility_timeout_seconds, 30)
}

# CREATE POLICY FOR SQS QUEUE RESOURCE
resource "aws_sqs_queue_policy" "sqs_policy" {
  for_each  = local.sqs_queue
  queue_url = aws_sqs_queue.queue[each.key].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.queue[each.key].arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.sns.arn}"
        }
      }
    }
  ]
}
POLICY
}