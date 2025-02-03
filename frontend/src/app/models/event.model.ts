import { EventTypeEnum } from "./enums/event-type.enum";
import { GroupTypeEnum } from "./enums/group-type.enum";

export interface EventModel {
    id: number;
    name: string;
    type: EventTypeEnum;
    startDate: Date;
    endDate: Date;
    maxParticipants: number;
    currentParticipants: number;
    imagePath?: string;
    parentId?: number;
    subevents?: EventModel[];
    groups?: GroupTypeEnum[];
}