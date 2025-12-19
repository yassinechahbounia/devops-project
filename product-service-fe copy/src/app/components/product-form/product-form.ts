import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { ProductService } from '../../services/product';
import { Product } from '../../models/product';

@Component({
  selector: 'app-product-form',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './product-form.html',
  styleUrls: ['./product-form.css']
})
export class ProductFormComponent implements OnInit {

  product: Product = {
    name: '',
    price: 0,
    quantity: 0,
    category: ''
  };

  isEditMode = false;
  productId!: number;

  constructor(
    private productService: ProductService,
    private route: ActivatedRoute,
    private router: Router
  ) {}

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');
    if (id) {
      this.isEditMode = true;
      this.productId = +id;
      this.productService.getById(this.productId).subscribe(p => {
        this.product = p;
      });
    }
  }

  save() {
    if (this.isEditMode) {
      this.productService.update(this.productId, this.product)
        .subscribe(() => this.router.navigate(['/']));
    } else {
      this.productService.create(this.product)
        .subscribe(() => this.router.navigate(['/']));
    }
  }

  cancel() {
    this.router.navigate(['/']);
  }
}
