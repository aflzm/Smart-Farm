import { Identity } from './Identity';
import { Scope } from './Scope';

export class Auth {
  identity: Identity = new Identity();
  scope: Scope = new Scope();
}