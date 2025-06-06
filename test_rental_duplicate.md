# Rental Duplicate Prevention Test Plan

## ✅ Implemented Changes

### 1. Database Helper Enhancement (`database_helper.dart`)
- ✅ Added `rentalHours` parameter to `rentMovie` method
- ✅ Added duplicate rental prevention check
- ✅ Returns `null` if rental already exists for same user + movie combination
- ✅ Supports both hours and days for rental duration

### 2. Rental Page Enhancement (`rental_page.dart`)
- ✅ Changed from `rentalDays: 0` to `rentalHours: 6`
- ✅ Added handling for duplicate rental attempts
- ✅ Shows appropriate message: "Anda sudah menyewa film ini!"

## 🧪 Testing Steps

### Test Case 1: First Rental (Should Succeed)
1. Login to the app
2. Navigate to any movie detail page
3. Click "Sewa Film - Rp 10.000/6 jam" button
4. Complete the rental process
5. **Expected**: Rental succeeds, button changes to "Anda Sudah Menyewa"

### Test Case 2: Duplicate Rental Prevention (Should Fail)
1. Try to rent the same movie again from detail page
2. **Expected**: Button should be disabled (grey) showing "Anda Sudah Menyewa"

### Test Case 3: Duplicate Rental via Navigation (Should Fail)
1. Navigate away and back to the same movie detail page
2. Try accessing rental page directly (if possible)
3. Complete rental form
4. **Expected**: Shows orange message "Anda sudah menyewa film ini!"

### Test Case 4: Different Movie (Should Succeed)
1. Navigate to a different movie detail page
2. Try to rent that movie
3. **Expected**: Rental should succeed normally

### Test Case 5: Different User (Should Succeed)
1. Logout and login with different user account
2. Try to rent the same movie that was rented by previous user
3. **Expected**: Rental should succeed normally

## 🔧 Key Implementation Details

### Database Logic
```dart
// Check if user already has an active rental for this movie
final existingRental = _movieRentalBox.values
    .where((rental) =>
        rental.userId == userId &&
        rental.movieId == movieId &&
        rental.expiryDate.isAfter(DateTime.now()))
    .firstOrNull;

if (existingRental != null) {
    return null; // Rental already exists
}
```

### Rental Duration
- **Before**: `rentalDays: 0` (immediate expiry)
- **After**: `rentalHours: 6` (6-hour duration)

### User Feedback
- **Success**: Normal rental flow + success page
- **Duplicate**: Orange SnackBar "Anda sudah menyewa film ini!"
- **UI State**: Button disabled and grey when already rented

## 🎯 Business Rules Enforced

1. **One Active Rental Per User Per Movie**: Prevents multiple rentals of same movie
2. **Time-Based Expiry**: Only active (non-expired) rentals block new rentals
3. **User Isolation**: Different users can rent the same movie
4. **Proper Duration**: 6-hour rental period instead of immediate expiry
