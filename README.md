# RoboShop – Shell Script Automated Microservices Deployment

A fully automated Bash-based deployment suite for the **RoboShop** e-commerce platform — a multi-service application built on a polyglot microservices architecture. Each script provisions, configures, and starts an individual service on Amazon Linux / RHEL-based EC2 instances.

---

## Architecture Overview

```
Internet → Nginx (Frontend) → Microservices → Databases & Message Brokers
                                  │
          ┌───────────────────────┼────────────────────────┐
          │                       │                        │
       Catalogue              Cart / User            Shipping / Payment
       (Node.js)              (Node.js)              (Java / Python)
          │                       │                        │
       MongoDB                 Redis                    MySQL
                                                       RabbitMQ
```

---

## Project Structure

```
roboshop-shell/
├── 01-ec2-create.sh        # Provision EC2 instances + Route53 DNS records
├── 02-mongodb.sh           # Install & configure MongoDB (remote access enabled)
├── 03-catalogue.sh         # Node.js catalogue service + MongoDB data load
├── 03-catalogue-e.sh       # Enhanced catalogue script with ERR trap & pipefail
├── 04-redis.sh             # Redis 7 install + remote connection config
├── 05-mysql.sh             # MySQL Server install + secure root password setup
├── 06-rabbitMQ.sh          # RabbitMQ install + user/permission setup
├── 07-user.sh              # Node.js user service deployment
├── 08-cart.sh              # Node.js cart service deployment
├── 09-shipping.sh          # Java (Maven) shipping service + MySQL schema load
├── 10-payment.sh           # Python payment service + pip dependencies
├── 11-frontend.sh          # Nginx 1.24 frontend deployment + custom nginx.conf
└── nginx.conf              # Nginx reverse proxy configuration
```

---

## Services & Technology Stack

| Service    | Runtime         | Database       | Port  |
|------------|-----------------|----------------|-------|
| Frontend   | Nginx 1.24      | —              | 80    |
| Catalogue  | Node.js 20      | MongoDB        | 8080  |
| User       | Node.js 20      | MongoDB, Redis | 8080  |
| Cart       | Node.js 20      | Redis          | 8080  |
| Shipping   | Java (Maven)    | MySQL          | 8080  |
| Payment    | Python 3        | RabbitMQ       | 8080  |
| MongoDB    | MongoDB Org     | —              | 27017 |
| Redis      | Redis 7         | —              | 6379  |
| MySQL      | MySQL Server    | —              | 3306  |
| RabbitMQ   | RabbitMQ Server | —              | 5672  |

---

## Key Features

- **Idempotent execution** — scripts check for existing users, databases, and services before recreating them (safe to re-run)
- **Centralized logging** — all output redirected to `/var/log/shell-logs/<script>.log` with timestamped entries
- **Color-coded terminal output** — GREEN for success, RED for errors, YELLOW for skipped steps
- **VALIDATOR function** — reusable exit-code checker used across all scripts; halts on first failure
- **Root privilege enforcement** — each script validates `$USERID` before executing
- **AWS CLI integration** — `01-ec2-create.sh` automates EC2 provisioning and Route53 DNS A-record creation via AWS CLI
- **Dynamic DNS mapping** — frontend gets a public IP record; all backend services get private IP subdomains (e.g., `mongodb.anuragaws.shop`)
- **Error trapping** (`03-catalogue-e.sh`) — uses `set -euo pipefail` and `trap ERR` to catch and report the exact line/command that failed
- **Execution time tracking** — `START_TIME`/`END_TIME` benchmarking in infrastructure scripts (Redis, MySQL, RabbitMQ)

---

## Prerequisites

- RHEL / Amazon Linux 2023 EC2 instances
- AWS CLI configured with appropriate IAM permissions (EC2 + Route53)
- A registered domain hosted in Route53
- Security groups allowing inter-service communication on required ports

---

## Usage

### Step 1 — Provision EC2 Instances
```bash
chmod +x 01-ec2-create.sh
./01-ec2-create.sh mongodb catalogue redis mysql rabbitmq user cart shipping payment frontend
```
This creates one EC2 instance per service and registers DNS A-records in Route53.

### Step 2 — Deploy Services (run each on its respective EC2 instance)
```bash
# On MongoDB instance
sudo bash 02-mongodb.sh

# On Catalogue instance
sudo bash 03-catalogue.sh

# On Redis instance
sudo bash 04-redis.sh

# On MySQL instance
sudo bash 05-mysql.sh

# On RabbitMQ instance
sudo bash 06-rabbitMQ.sh

# On User instance
sudo bash 07-user.sh

# On Cart instance
sudo bash 08-cart.sh

# On Shipping instance
sudo bash 09-shipping.sh

# On Payment instance
sudo bash 10-payment.sh

# On Frontend instance
sudo bash 11-frontend.sh
```

---

## Logging

All scripts write structured logs to:
```
/var/log/shell-logs/<script-name>.log
```
Each log entry captures success/failure of every step, making debugging straightforward without re-running the full script.

---

## Domain Configuration

The project uses `anuragaws.shop` as the base domain. Services are auto-registered as subdomains:

| Service    | DNS Record                      | IP Type  |
|------------|---------------------------------|----------|
| Frontend   | `anuragaws.shop`                | Public   |
| MongoDB    | `mongodb.anuragaws.shop`        | Private  |
| MySQL      | `mysql.anuragaws.shop`          | Private  |
| Redis      | `redis.anuragaws.shop`          | Private  |
| RabbitMQ   | `rabbitmq.anuragaws.shop`       | Private  |
| Catalogue  | `catalogue.anuragaws.shop`      | Private  |
| User       | `user.anuragaws.shop`           | Private  |
| Cart       | `cart.anuragaws.shop`           | Private  |
| Shipping   | `shipping.anuragaws.shop`       | Private  |
| Payment    | `payment.anuragaws.shop`        | Private  |

---

## Author

**Anurag Bojja**  
Milwaukee, WI | [LinkedIn](https://www.linkedin.com/in/anurag-bojja-81a405192/) | [GitHub](https://github.com/AnuragBojja)
