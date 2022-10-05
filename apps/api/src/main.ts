import * as express from 'express';
import { faker } from '@faker-js/faker';
import { addTodoRoutes } from './app/todos';

const app = express();

app.get('/api', (req, res) => {
  res.send({ message: 'Welcome to api!' + faker.name.firstName() });
});
addTodoRoutes(app);

const port = process.env.port || 3333;
const server = app.listen(port, () => {
  console.log(`Listening at http://localhost:${port}/api`);
});
server.on('error', console.error);
