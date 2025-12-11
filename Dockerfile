# -------------------------------
# STEP 1 — Base image
# -------------------------------
FROM node:18-alpine

# Create working directory inside the container
WORKDIR /app

# -------------------------------
# STEP 2 — Copy dependency files
# -------------------------------
COPY package.json package-lock.json ./

# Install dependencies (Hardhat, toolbox, etc)
RUN npm install

# -------------------------------
# STEP 3 — Copy full project
# -------------------------------
COPY . .

# -------------------------------
# STEP 4 — Compile contracts
# -------------------------------
RUN npx hardhat compile

# -------------------------------
# STEP 5 — Default command (runs tests)
# -------------------------------
CMD ["npx", "hardhat", "test"]
