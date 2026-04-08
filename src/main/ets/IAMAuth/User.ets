import { Domain } from './Domain';

export class User {
  name: string = '';
  password: string = '';
  domain: Domain = new Domain();
}