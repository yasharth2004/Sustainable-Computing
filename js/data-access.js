import {db} from './database.js';
import {resources} from './resource-manager.js';
import {campaigns} from './campaign-manager.js';
import {cloud} from './cloud-data.js';
import {supabase} from './supabase-client.js';

export const dataAccess={
  mode:()=>supabase.isConfigured()?'cloud':'demo',
  resources:()=>cloud.isAvailable()?cloud.fetchResources():Promise.resolve(resources.all()),
  campaigns:()=>cloud.isAvailable()?cloud.fetchCampaigns():Promise.resolve(campaigns.all()),
  saveDemo:db.save,
  cloud
};