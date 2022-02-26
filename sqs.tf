# CREATE SQS QUEUE RESOURCE
resource "aws_sqs_queue" "queue" {
  for_each                  = local.sqs_queue
  name                      = each.value.name
  delay_seconds             = try(each.value.delay_seconds, 0)
  max_message_size          = try(each.value.max_message_size, 262144)
  message_retention_seconds = try(each.value.message_retention_seconds, 345600)
  receive_wait_time_seconds = try(each.value.receive_wait_time_seconds, 0)
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = try(each.value.dlq_retries, 5)
  })
}

# CREATE SQS DLQ RESOURCE
resource "aws_sqs_queue" "dlq" {
  for_each                  = local.sqs_queue
  name                      = replace(each.value.name, "queue", "dlq")
  delay_seconds             = try(each.value.delay_seconds, 0)
  max_message_size          = try(each.value.max_message_size, 262144)
  message_retention_seconds = try(each.value.message_retention_seconds, 1209600)
  receive_wait_time_seconds = try(each.value.receive_wait_time_seconds, 0)
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
          "aws:SourceArn": "${aws_sns_topic.sns_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}