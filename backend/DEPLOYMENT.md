# Deployment Guide - Google Maps Nigeria App Backend

## Quick Deploy Options

### Option 1: Railway (Recommended - Easiest)

**Why Railway:**
- Free tier available
- Automatic HTTPS
- Easy MongoDB integration
- GitHub auto-deploy
- Nigerian payment methods accepted

**Steps:**

1. **Create Railway Account**
```bash
# Visit railway.app and sign up with GitHub
```

2. **Deploy from GitHub**
```bash
# Push your code to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/maps-nigeria-backend.git
git push -u origin main

# On Railway dashboard:
# 1. Click "New Project"
# 2. Select "Deploy from GitHub repo"
# 3. Choose your repository
# 4. Railway auto-detects Node.js
```

3. **Add MongoDB**
```bash
# In Railway project:
# 1. Click "New" → "Database" → "Add MongoDB"
# 2. Copy connection string
# 3. Add to environment variables
```

4. **Set Environment Variables**
```bash
# In Railway project settings → Variables:
NODE_ENV=production
MONGODB_URI=mongodb://...  # From Railway MongoDB
JWT_SECRET=your-secret-key
PAYSTACK_SECRET_KEY=sk_live_...
# ... add all other variables from .env.example
```

5. **Deploy**
```bash
# Railway auto-deploys on git push
# Your API will be live at: https://your-app.railway.app
```

**Cost:**
- Free: $5 credit/month (enough for testing)
- Hobby: $5/month (good for 10k users)
- Pro: $20/month (good for 100k users)

---

### Option 2: Render

**Why Render:**
- Free tier with custom domain
- Auto-scaling
- Easy database backups

**Steps:**

1. **Create Render Account**
```bash
# Visit render.com and sign up
```

2. **Create Web Service**
```bash
# 1. Click "New +" → "Web Service"
# 2. Connect GitHub repository
# 3. Configure:
#    - Name: maps-nigeria-api
#    - Environment: Node
#    - Build Command: npm install
#    - Start Command: npm start
#    - Plan: Free
```

3. **Add MongoDB Atlas**
```bash
# 1. Visit mongodb.com/cloud/atlas
# 2. Create free cluster
# 3. Get connection string
# 4. Add to Render environment variables
```

4. **Set Environment Variables**
```bash
# In Render dashboard → Environment:
# Add all variables from .env.example
```

**Cost:**
- Free: 750 hours/month (enough for 1 service)
- Starter: $7/month
- Standard: $25/month

---

### Option 3: Heroku

**Steps:**

1. **Install Heroku CLI**
```bash
npm install -g heroku
heroku login
```

2. **Create Heroku App**
```bash
cd backend
heroku create maps-nigeria-api
```

3. **Add MongoDB**
```bash
heroku addons:create mongolab:sandbox
```

4. **Set Environment Variables**
```bash
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your-secret
# ... set all other variables
```

5. **Deploy**
```bash
git push heroku main
heroku open
```

**Cost:**
- Eco: $5/month
- Basic: $7/month
- Standard: $25/month

---

## Database Setup

### MongoDB Atlas (Recommended)

1. **Create Account**
```bash
# Visit mongodb.com/cloud/atlas
# Sign up for free
```

2. **Create Cluster**
```bash
# 1. Click "Build a Database"
# 2. Choose "Shared" (Free)
# 3. Select AWS, Region: eu-west-1 (Ireland - closest to Nigeria)
# 4. Cluster Name: maps-nigeria
```

3. **Create Database User**
```bash
# 1. Security → Database Access
# 2. Add New Database User
# 3. Username: mapsadmin
# 4. Password: Generate secure password
# 5. Database User Privileges: Read and write to any database
```

4. **Whitelist IP**
```bash
# 1. Security → Network Access
# 2. Add IP Address
# 3. Allow Access from Anywhere: 0.0.0.0/0
# (For production, use specific IPs)
```

5. **Get Connection String**
```bash
# 1. Database → Connect
# 2. Connect your application
# 3. Copy connection string
# mongodb+srv://mapsadmin:<password>@maps-nigeria.xxxxx.mongodb.net/
```

---

## Domain Setup

### Custom Domain (Optional)

1. **Buy Domain**
```bash
# Recommended Nigerian registrars:
# - Whogohost.com
# - Qservers.net
# - Web4Africa.com

# Suggested domains:
# - mapsnigeria.com
# - naijanav.com
# - routeng.com
```

2. **Configure DNS**
```bash
# Add CNAME record:
# Type: CNAME
# Name: api
# Value: your-app.railway.app (or render.com)
# TTL: 3600

# Your API will be accessible at:
# https://api.mapsnigeria.com
```

3. **SSL Certificate**
```bash
# Railway/Render automatically provides SSL
# No additional configuration needed
```

---

## CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Use Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: cd backend && npm install
      - run: cd backend && npm test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Railway
        run: |
          npm install -g @railway/cli
          railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## Monitoring & Analytics

### 1. Application Monitoring

**Sentry (Error Tracking)**
```bash
npm install @sentry/node

# In server.js:
const Sentry = require("@sentry/node");
Sentry.init({ dsn: process.env.SENTRY_DSN });
```

**New Relic (Performance)**
```bash
npm install newrelic

# Create newrelic.js config
# Add to start of server.js:
require('newrelic');
```

### 2. Uptime Monitoring

**UptimeRobot (Free)**
```bash
# Visit uptimerobot.com
# Add monitor:
# - Type: HTTPS
# - URL: https://your-api.com/health
# - Interval: 5 minutes
# - Alert: Email/SMS when down
```

### 3. Analytics

**Google Analytics**
```bash
# Track API usage:
# - Endpoint hits
# - User registrations
# - Premium conversions
# - Error rates
```

---

## Security Checklist

### Before Going Live:

- [ ] Change all default passwords
- [ ] Rotate JWT secrets
- [ ] Enable HTTPS only
- [ ] Set up rate limiting
- [ ] Configure CORS properly
- [ ] Enable MongoDB authentication
- [ ] Set up database backups
- [ ] Configure firewall rules
- [ ] Enable audit logging
- [ ] Set up SSL certificates
- [ ] Configure environment variables
- [ ] Remove debug logs
- [ ] Set up error monitoring
- [ ] Configure API rate limits
- [ ] Enable request validation
- [ ] Set up DDoS protection
- [ ] Configure session management
- [ ] Enable security headers (Helmet.js)
- [ ] Set up intrusion detection
- [ ] Configure backup strategy

---

## Backup Strategy

### Database Backups

**Automated Backups (MongoDB Atlas)**
```bash
# 1. Atlas Dashboard → Backup
# 2. Enable Cloud Backup
# 3. Schedule: Daily at 2 AM WAT
# 4. Retention: 7 days
# 5. Download backups weekly
```

**Manual Backup**
```bash
# Export database
mongodump --uri="mongodb+srv://..." --out=./backup

# Restore database
mongorestore --uri="mongodb+srv://..." ./backup
```

### Code Backups

```bash
# GitHub (automatic)
git push origin main

# Additional backup to GitLab
git remote add gitlab https://gitlab.com/...
git push gitlab main
```

---

## Scaling Strategy

### Vertical Scaling (Increase Resources)

**When to scale:**
- CPU usage > 70%
- Memory usage > 80%
- Response time > 500ms
- Error rate > 1%

**Railway scaling:**
```bash
# Upgrade plan:
# Hobby → Pro: $20/month
# Increases: 8GB RAM, 8 vCPU
```

### Horizontal Scaling (Add Servers)

**Load Balancer Setup:**
```bash
# Use Railway's built-in load balancing
# Or configure Nginx:

upstream backend {
    server api1.mapsnigeria.com;
    server api2.mapsnigeria.com;
    server api3.mapsnigeria.com;
}

server {
    listen 80;
    location / {
        proxy_pass http://backend;
    }
}
```

### Database Scaling

**Read Replicas:**
```bash
# MongoDB Atlas:
# 1. Cluster → Configuration
# 2. Add Read Replica
# 3. Region: eu-west-1
# 4. Update connection string for read operations
```

**Sharding (for 1M+ users):**
```bash
# Shard by userId
# Each shard handles 250k users
```

---

## Cost Optimization

### Month 1-3 (Testing Phase)
- Railway Free Tier: $0
- MongoDB Atlas Free: $0
- Domain: ₦5,000/year
- **Total: ₦5,000 (~$6)**

### Month 4-6 (Launch Phase)
- Railway Hobby: $5/month
- MongoDB Atlas M10: $10/month
- Sentry: $0 (free tier)
- **Total: $15/month (₦12,500)**

### Month 7-12 (Growth Phase)
- Railway Pro: $20/month
- MongoDB Atlas M20: $40/month
- Sentry Pro: $26/month
- CDN (Cloudflare): $0 (free)
- **Total: $86/month (₦72,000)**

### Year 2 (Scale Phase)
- Railway Pro: $20/month
- MongoDB Atlas M30: $100/month
- Sentry Business: $89/month
- CDN: $20/month
- **Total: $229/month (₦191,000)**

---

## Launch Checklist

### Pre-Launch (1 week before)

- [ ] Deploy to production
- [ ] Test all API endpoints
- [ ] Verify payment integration
- [ ] Test mobile app connection
- [ ] Set up monitoring
- [ ] Configure backups
- [ ] Test error handling
- [ ] Load testing (1000 concurrent users)
- [ ] Security audit
- [ ] Documentation complete

### Launch Day

- [ ] Monitor error rates
- [ ] Watch server metrics
- [ ] Check payment processing
- [ ] Monitor user registrations
- [ ] Track API response times
- [ ] Be ready for hotfixes

### Post-Launch (1 week after)

- [ ] Analyze user behavior
- [ ] Fix reported bugs
- [ ] Optimize slow endpoints
- [ ] Adjust rate limits
- [ ] Review error logs
- [ ] Collect user feedback

---

## Support & Maintenance

### Daily Tasks
- Check error logs
- Monitor uptime
- Review user feedback

### Weekly Tasks
- Database backup verification
- Performance analysis
- Security updates
- User analytics review

### Monthly Tasks
- Cost optimization review
- Feature usage analysis
- A/B test results
- Server capacity planning

---

## Emergency Procedures

### Server Down

1. Check Railway/Render status page
2. Check MongoDB Atlas status
3. Review error logs
4. Restart service if needed
5. Notify users via social media

### Database Issues

1. Check MongoDB Atlas metrics
2. Verify connection string
3. Check disk space
4. Restore from backup if needed

### Payment Issues

1. Check Paystack dashboard
2. Verify webhook endpoint
3. Check transaction logs
4. Contact Paystack support

---

## Getting Help

### Resources

- **Railway Docs**: docs.railway.app
- **MongoDB Docs**: docs.mongodb.com
- **Paystack Docs**: paystack.com/docs
- **Node.js Docs**: nodejs.org/docs

### Community

- **Railway Discord**: railway.app/discord
- **MongoDB Community**: community.mongodb.com
- **Nigerian Dev Community**: devcenter.ng

### Support

- **Railway**: support@railway.app
- **MongoDB**: support.mongodb.com
- **Paystack**: support@paystack.com

---

## Next Steps

1. **Deploy backend** to Railway/Render
2. **Set up MongoDB** Atlas
3. **Configure Paystack** for payments
4. **Update mobile app** with API URL
5. **Test end-to-end** flow
6. **Launch** to users!

Your backend is now ready for production! 🚀
