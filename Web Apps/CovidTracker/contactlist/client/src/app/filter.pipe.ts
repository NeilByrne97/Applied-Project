import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'filter'
})
export class FilterPipe implements PipeTransform {
  transform(items: any[], test: string): any[] {

    if (!items) {
      return [];
    }
    if (!test) {
      return items;
    }
   test = test;
    console.log('SEARCH TEXT: ', test)
    console.log('SEARCH ITEMS: ',items)

    return  items.filter(o => { 
      console.log('SEARCH timestamps: ',o.timestamp)
     // return o.timestamp.toDateString().includes(test)
      return new Date(o.timestamp).toDateString().includes(test)
    });
   
  }
}