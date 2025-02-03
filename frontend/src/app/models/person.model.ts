import { RoleTypeEnum } from "./enums/role-type.enum";
import { GroupTypeEnum } from "./enums/group-type.enum";

export interface PersonModel {
    id: number;
    firstName: string;
    surname: string;
    role: RoleTypeEnum;
    group?: GroupTypeEnum; // Optional field
    UserId?: number; // Optional field
  }