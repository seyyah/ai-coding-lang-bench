import math

class DataValidator:
    """
    Extension for SPEC-v2 compliance.
    Validates numeric inputs and handles non-numeric exceptions.
    """
    
    @staticmethod
    def validate_numeric(value, field_name="Value"):
        """
        Validates that a field is a finite number.
        Raises ValueError if non-numeric or non-finite.
        """
        # Check for None or Empty String
        if value is None or (isinstance(value, str) and value.strip() == ""):
            raise ValueError(f"Validation Error: '{field_name}' cannot be null or empty.")

        # Check for Type (ensure it's not a boolean as they are instances of int)
        if not isinstance(value, (int, float)) or isinstance(value, bool):
            raise TypeError(f"Validation Error: '{field_name}' must be a numeric type (got {type(value).__name__}).")

        # Check for NaN or Infinity
        if not math.isfinite(value):
            raise ValueError(f"Validation Error: '{field_name}' must be a finite number.")

        return True

def process_data(data_packet):
    """
    Example integration of the new validation logic.
    """
    try:
        # Assuming data_packet contains keys specified in SPEC-v2
        for key, val in data_packet.items():
            DataValidator.validate_numeric(val, field_name=key)
        
        # Proceed with existing business logic
        # ... 
        
    except (ValueError, TypeError) as e:
        # SPEC-v2 requirement: Log and handle non-numeric violation
        print(f"SPEC-v2 Violation: {e}")
        return None