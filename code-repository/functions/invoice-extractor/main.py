#-------------------------------------
# Cloud Run Function to extract invoice
#-------------------------------------
import os
import json
from typing import List, Optional
import functions_framework
from pydantic import BaseModel, Field
from google import genai
from google.genai import types

class LineItem(BaseModel):
    description: str = Field(description="Description of the item or service")
    quantity: Optional[float] = Field(default=1.0, description="Quantity of units")
    unit_price: Optional[float] = Field(default=None, description="Price per unit")
    amount: float = Field(description="Total line item amount")

class InvoiceExtraction(BaseModel):
    invoice_number: Optional[str] = Field(default=None, description="Invoice or reference number")
    invoice_date: Optional[str] = Field(default=None, description="Invoice issue date in YYYY-MM-DD format")
    due_date: Optional[str] = Field(default=None, description="Payment due date")
    vendor_name: Optional[str] = Field(default=None, description="Name of company issuing the invoice")
    customer_name: Optional[str] = Field(default=None, description="Client or company being billed")
    line_items: List[LineItem] = Field(default_factory=list, description="List of invoiced line items")
    subtotal: Optional[float] = Field(default=None, description="Subtotal amount before tax")
    tax_amount: Optional[float] = Field(default=None, description="Tax or VAT amount")
    total_amount: float = Field(description="Final total payable amount")
    currency: Optional[str] = Field(default="USD", description="Currency symbol or code")

# Dynamically injected by Terraform environment_variables
PROJECT_ID = os.environ["GCP_PROJECT_ID"]
LOCATION = os.environ.get("GCP_LOCATION", "asia-south1")

client = genai.Client(
    vertexai=True,
    project=PROJECT_ID,
    location=LOCATION
)

@functions_framework.http
def extract_invoice(request):
    if request.method == "OPTIONS":
        headers = {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Max-Age": "3600"
        }
        return ("", 204, headers)

    headers = {"Access-Control-Allow-Origin": "*", "Content-Type": "application/json"}
    request_json = request.get_json(silent=True)

    if not request_json or "invoice_text" not in request_json:
        return (json.dumps({"error": "Missing 'invoice_text' parameter"}), 400, headers)

    try:
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=request_json["invoice_text"],
            config=types.GenerateContentConfig(
                system_instruction="Extract structured invoice details accurately conforming to the requested schema.",
                response_mime_type="application/json",
                response_schema=InvoiceExtraction,
                temperature=0.1,
            )
        )
        return (response.text, 200, headers)
    except Exception as e:
        return (json.dumps({"error": str(e)}), 500, headers)