import { Routes } from '@angular/router';
import { ProductListComponent } from './components/product-list/product-list';
import { ProductFormComponent } from './components/product-form/product-form';

export const routes: Routes = [
  { path: '', component: ProductListComponent },
  { path: 'create', component: ProductFormComponent },
  { path: 'edit/:id', component: ProductFormComponent }
];
