import { CommonModule } from '@angular/common';
import { Component, EventEmitter, Output, Input } from '@angular/core';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-filter',
  standalone: true,
  templateUrl: './filter.component.html',
  styleUrls: ['./filter.component.css'],
  imports: [CommonModule, FormsModule]
})
export class FilterComponent {
  filterTerm: string = '';
  @Input() filterByName: string = '';

  @Output() filterChanged = new EventEmitter<string>();

  onFilterChange() {
    this.filterChanged.emit(this.filterTerm);
  }

  resetFilter() {
    this.filterTerm = '';
    this.filterChanged.emit(this.filterTerm);
  }
}
