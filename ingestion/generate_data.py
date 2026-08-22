"""Generate Kenyan insurance source-system CSV files for the dbt staging models."""

import argparse
import csv
import random
from datetime import date, datetime, timedelta
from decimal import Decimal
from pathlib import Path

from faker import Faker


TABLE_COLUMNS = {
	"agents": ["created_at", "created_by", "updated_at", "updated_by", "agent_id", "first_name", "last_name", "email", "phone_number", "hire_date", "job_id", "salary", "commission_pct", "manager_id", "department_id", "active"],
	"beneficiaries": ["created_at", "created_by", "updated_at", "updated_by", "beneficiary_id", "policy_id", "first_name", "last_name", "email", "phone_number", "active"],
	"branches": ["created_at", "created_by", "updated_at", "updated_by", "branch_id", "branch_name", "address", "city", "state", "zip_code", "active"],
	"claims": ["created_at", "created_by", "updated_at", "updated_by", "claim_id", "claim_date", "policy_id", "agent_id", "beneficiary_id", "branch_id", "claim_amount", "reserve_amount", "settlement_amount", "cause_of_loss", "status", "active"],
	"claim_settlements": ["created_at", "created_by", "updated_at", "updated_by", "claim_settlement_id", "claim_id", "settlement_amount", "settlement_date", "method", "reference", "approved_by", "status", "active"],
	"customers": ["created_at", "created_by", "updated_at", "updated_by", "customer_id", "national_id", "first_name", "last_name", "email", "phone_number", "date_of_birth", "gender", "address", "city", "state", "zip_code", "active"],
	"payments": ["created_at", "created_by", "updated_at", "updated_by", "payment_id", "claim_id", "policy_id", "payment_date", "amount", "method", "reference", "active"],
	"policies": ["created_at", "created_by", "updated_at", "updated_by", "policy_id", "policy_number", "customer_id", "type", "issue_date", "expiry_date", "premium_amount", "agent_id", "beneficiary_id", "branch_id", "status", "sum_assured", "active"],
	"policy_endorsements": ["created_at", "created_by", "updated_at", "updated_by", "policy_endorsement_id", "policy_id", "endorsement_date", "endorsement_type", "old_value", "new_value", "premium_adjustment", "approved_by", "active"],
	"products": ["created_at", "created_by", "updated_at", "updated_by", "product_id", "product_name", "product_description", "product_type", "min_amount", "max_amount", "active"],
}

COUNTIES = [("Nairobi", "Nairobi", "00100"), ("Mombasa", "Mombasa", "80100"), ("Kisumu", "Kisumu", "40100"), ("Nakuru", "Nakuru", "20100"), ("Kiambu", "Thika", "01000"), ("Uasin Gishu", "Eldoret", "30100"), ("Machakos", "Machakos", "90100"), ("Meru", "Meru", "60200")]
PAYMENT_METHODS = ["M-Pesa", "Bank Transfer", "Card", "Cash", "Cheque"]
PRODUCTS = [("Motor Private", "Motor", 15000, 5000000), ("Afya Bora Medical", "Medical", 30000, 2500000), ("Msingi Life", "Life", 20000, 10000000), ("Biashara Fire", "Fire", 25000, 15000000), ("Safari Travel", "Travel", 5000, 1000000)]


def money(value: Decimal | float | int) -> str:
	return f"{Decimal(str(value)).quantize(Decimal('0.01')):.2f}"


def iso_datetime(value: datetime) -> str:
	return value.replace(microsecond=0).isoformat(sep=" ")


def generate_data(seed: int, counts: dict[str, int]) -> dict[str, list[dict[str, object]]]:
	fake = Faker("en_US")
	fake.seed_instance(seed)
	rng = random.Random(seed)
	now = datetime(2026, 1, 15, 10, 0, 0)
	data = {table: [] for table in TABLE_COLUMNS}

	def audit() -> dict[str, str]:
		created = now - timedelta(days=rng.randint(30, 900))
		return {"created_at": iso_datetime(created), "created_by": "seed_generator", "updated_at": iso_datetime(created + timedelta(days=rng.randint(0, 30))), "updated_by": "seed_generator"}

	for index in range(1, counts["branches"] + 1):
		county, city, postal_code = rng.choice(COUNTIES)
		row = audit()
		row.update(branch_id=f"BR{index:04d}", branch_name=f"{city} {rng.choice(['CBD', 'Mall', 'Town'])} Branch", address=fake.street_address(), city=city, state=county, zip_code=postal_code, active=rng.random() > 0.08)
		data["branches"].append(row)

	for index in range(1, counts["agents"] + 1):
		first_name, last_name = fake.first_name(), fake.last_name()
		row = audit()
		row.update(agent_id=f"AG{index:05d}", first_name=first_name, last_name=last_name, email=f"{first_name}.{last_name}.{index}@coverhouse.co.ke".lower(), phone_number=f"+2547{rng.randint(10000000, 99999999)}", hire_date=(date(2015, 1, 1) + timedelta(days=rng.randint(0, 3800))).isoformat(), job_id=rng.choice(["SALES_AGENT", "BROKER", "TEAM_LEAD"]), salary=money(rng.randint(45000, 220000)), commission_pct=money(rng.uniform(2, 12)), manager_id=None if index <= 2 else f"AG{rng.randint(1, 2):05d}", department_id=rng.choice(["MOTOR", "LIFE", "MEDICAL", "SME"]), active=rng.random() > 0.05)
		data["agents"].append(row)

	for index in range(1, counts["customers"] + 1):
		first_name, last_name = fake.first_name(), fake.last_name()
		county, city, postal_code = rng.choice(COUNTIES)
		row = audit()
		row.update(customer_id=f"CU{index:06d}", national_id=str(rng.randint(10000000, 39999999)), first_name=first_name, last_name=last_name, email=f"{first_name}.{last_name}.{index}@example.co.ke".lower(), phone_number=f"+2547{rng.randint(10000000, 99999999)}", date_of_birth=(date(1960, 1, 1) + timedelta(days=rng.randint(0, 18000))).isoformat(), gender=rng.choice(["Female", "Male"]), address=fake.street_address(), city=city, state=county, zip_code=postal_code, active=rng.random() > 0.04)
		data["customers"].append(row)

	for index, (name, product_type, minimum, maximum) in enumerate(PRODUCTS, 1):
		row = audit()
		row.update(product_id=f"PR{index:03d}", product_name=name, product_description=f"{name} insurance cover for the Kenyan market", product_type=product_type, min_amount=money(minimum), max_amount=money(maximum), active=True)
		data["products"].append(row)

	for index in range(1, counts["policies"] + 1):
		product = rng.choice(PRODUCTS)
		issue_date = date(2024, 1, 1) + timedelta(days=rng.randint(0, 700))
		row = audit()
		row.update(policy_id=f"PO{index:07d}", policy_number=f"KE-{issue_date.year}-{index:08d}", customer_id=rng.choice(data["customers"])["customer_id"], type=product[1], issue_date=issue_date.isoformat(), expiry_date=(issue_date + timedelta(days=365)).isoformat(), premium_amount=money(rng.randint(5000, 250000)), agent_id=rng.choice(data["agents"])["agent_id"], beneficiary_id=None, branch_id=rng.choice(data["branches"])["branch_id"], status=rng.choices(["Active", "Cancelled", "Expired", "Pending"], [60, 8, 25, 7])[0], sum_assured=money(rng.randint(product[2], product[3])), active=True)
		data["policies"].append(row)

	for index, policy in enumerate(data["policies"][:counts["beneficiaries"]], 1):
		first_name, last_name = fake.first_name(), fake.last_name()
		beneficiary_id = f"BE{index:07d}"
		row = audit()
		row.update(beneficiary_id=beneficiary_id, policy_id=policy["policy_id"], first_name=first_name, last_name=last_name, email=f"{first_name}.{last_name}.{index}@example.co.ke".lower(), phone_number=f"+2547{rng.randint(10000000, 99999999)}", active=True)
		data["beneficiaries"].append(row)
		policy["beneficiary_id"] = beneficiary_id

	for index in range(1, counts["claims"] + 1):
		policy = rng.choice(data["policies"])
		issue_date = date.fromisoformat(policy["issue_date"])
		claim_date = issue_date + timedelta(days=rng.randint(1, max(1, (now.date() - issue_date).days)))
		claim_amount = Decimal(rng.randint(10000, 800000))
		status = rng.choices(["Open", "Pending", "Approved", "Rejected", "Settled"], [20, 15, 20, 10, 35])[0]
		settlement_amount = Decimal("0.00") if status not in ["Approved", "Settled"] else claim_amount * Decimal(str(rng.uniform(0.55, 0.98)))
		row = audit()
		row.update(claim_id=f"CL{index:07d}", claim_date=claim_date.isoformat(), policy_id=policy["policy_id"], agent_id=policy["agent_id"], beneficiary_id=policy["beneficiary_id"], branch_id=policy["branch_id"], claim_amount=money(claim_amount), reserve_amount=money(claim_amount * Decimal("0.80")), settlement_amount=money(settlement_amount), cause_of_loss=rng.choice(["Road accident", "Theft", "Illness", "Fire", "Flood"]), status=status, active=True)
		data["claims"].append(row)

	settlement_index = 1
	for claim in data["claims"]:
		if settlement_index > counts["claim_settlements"]:
			break
		if claim["status"] not in ["Approved", "Settled"]:
			continue
		row = audit()
		row.update(claim_settlement_id=f"CS{settlement_index:07d}", claim_id=claim["claim_id"], settlement_amount=claim["settlement_amount"], settlement_date=(date.fromisoformat(claim["claim_date"]) + timedelta(days=rng.randint(7, 90))).isoformat(), method=rng.choice(PAYMENT_METHODS[:3]), reference=f"SET-{settlement_index:09d}", approved_by="claims.approvals@coverhouse.co.ke", status="Paid", active=True)
		data["claim_settlements"].append(row)
		settlement_index += 1

	claim_ids = [claim["claim_id"] for claim in data["claims"]]
	for index in range(1, counts["payments"] + 1):
		policy = rng.choice(data["policies"])
		row = audit()
		row.update(payment_id=f"PM{index:07d}", claim_id=rng.choice(claim_ids) if claim_ids and rng.random() < 0.15 else None, policy_id=policy["policy_id"], payment_date=(date.fromisoformat(policy["issue_date"]) + timedelta(days=rng.randint(1, 360))).isoformat(), amount=money(rng.randint(5000, 250000)), method=rng.choice(PAYMENT_METHODS), reference=f"RCT-{index:09d}", active=True)
		data["payments"].append(row)

	for index in range(1, counts["policy_endorsements"] + 1):
		policy = rng.choice(data["policies"])
		row = audit()
		row.update(policy_endorsement_id=f"EN{index:07d}", policy_id=policy["policy_id"], endorsement_date=policy["issue_date"], endorsement_type=rng.choice(["Upgrade", "Downgrade", "Add Cover", "Change Beneficiary"]), old_value="Standard", new_value="Enhanced", premium_adjustment=money(rng.randint(-10000, 30000)), approved_by="underwriting@coverhouse.co.ke", active=True)
		data["policy_endorsements"].append(row)

	return data


def write_csv_files(data: dict[str, list[dict[str, object]]], output_dir: Path) -> None:
	output_dir.mkdir(parents=True, exist_ok=True)
	for table, rows in data.items():
		with (output_dir / f"{table}.csv").open("w", newline="", encoding="utf-8") as csv_file:
			writer = csv.DictWriter(csv_file, fieldnames=TABLE_COLUMNS[table])
			writer.writeheader()
			writer.writerows(rows)


def main() -> None:
	parser = argparse.ArgumentParser(description=__doc__)
	parser.add_argument("--output-dir", type=Path, default=Path(__file__).parent / "data" / "raw")
	parser.add_argument("--seed", type=int, default=42)
	for name, default in {"customers": 250, "policies": 400, "claims": 180, "payments": 600, "beneficiaries": None, "agents": 40, "branches": 12, "claim-settlements": 100, "policy-endorsements": 120}.items():
		parser.add_argument(f"--{name}", type=int, default=default)
	args = parser.parse_args()
	counts = vars(args).copy()
	counts.pop("output_dir")
	counts.pop("seed")
	counts["beneficiaries"] = args.beneficiaries if args.beneficiaries is not None else args.policies
	write_csv_files(generate_data(args.seed, counts), args.output_dir)
	print(f"Generated {len(TABLE_COLUMNS)} CSV files in {args.output_dir}")


if __name__ == "__main__":
	main()
