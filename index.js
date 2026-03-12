const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('Hello World from Cloud Run!'));
app.listen(8080, '0.0.0.0');