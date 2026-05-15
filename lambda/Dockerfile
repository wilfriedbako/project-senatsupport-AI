FROM public.ecr.aws/lambda/python:3.11

COPY . ${LAMBDA_TASK_ROOT}

RUN pip install boto3 -t ${LAMBDA_TASK_ROOT}

CMD ["app.lambda_handler"]