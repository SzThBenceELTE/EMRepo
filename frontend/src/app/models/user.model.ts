import { RoleTypeEnum } from "./enums/role-type.enum";
import { PersonModel } from "./person.model";

export interface UserModel {
    id: number;
    name: string;
    email: string;
    password: string;
    Person: PersonModel;
  }