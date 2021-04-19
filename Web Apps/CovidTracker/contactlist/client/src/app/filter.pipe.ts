import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filter'
})
export class FilterPipe implements PipeTransform {
  transform(items: any[], searchText: string): any[] {

    if (!items) {
      return [];
    }
    if (!searchText) {
      return items;
    }
   searchText = searchText.toLocaleLowerCase();
   // console.log(items)

    return  items.filter(o => { return o.timestamp.toLocaleLowerCase().includes(searchText)
    });
   
  }
}