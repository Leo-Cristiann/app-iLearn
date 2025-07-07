class Validators {
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  // Username validator
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    return null;
  }
  
  // Required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  // Phone number validator
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  // URL validator
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9-_]+(.[a-zA-Z0-9-_]+)*(:[0-9]+)?(/[a-zA-Z0-9-_.]*)*(\?[a-zA-Z0-9-_]+=[a-zA-Z0-9-_%]+(&[a-zA-Z0-9-_]+=[a-zA-Z0-9-_%]+)*)?$',
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  // Number validator
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (int.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }
  
  // Maximum students validator
  static String? validateMaxStudents(String? value) {
    if (value == null || value.isEmpty) {
      return 'Maximum students is required';
    }
    
    final maxStudents = int.tryParse(value);
    
    if (maxStudents == null) {
      return 'Please enter a valid number';
    }
    
    if (maxStudents < 1) {
      return 'Maximum students must be at least 1';
    }
    
    if (maxStudents > 200) {
      return 'Maximum students cannot exceed 200';
    }
    
    return null;
  }
  
  // Quiz time limit validator
  static String? validateTimeLimit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time limit is required';
    }
    
    final timeLimit = int.tryParse(value);
    
    if (timeLimit == null) {
      return 'Please enter a valid number';
    }
    
    if (timeLimit < 1) {
      return 'Time limit must be at least 1 minute';
    }
    
    if (timeLimit > 180) {
      return 'Time limit cannot exceed 180 minutes (3 hours)';
    }
    
    return null;
  }
  
  // Date validator (must be in the future)
  static String? validateFutureDate(DateTime? date, String fieldName) {
    if (date == null) {
      return '$fieldName is required';
    }
    
    if (date.isBefore(DateTime.now())) {
      return '$fieldName must be in the future';
    }
    
    return null;
  }
}