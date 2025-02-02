import sanic

app = sanic.Sanic("AWSCICDApp")

@app.get("/")
async def index(request):
    return sanic.response.text("hello from AWS CI/CD example with python")

